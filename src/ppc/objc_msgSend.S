#include <machine/asm.h>

/*
 struct objc_super2
 {
    id        receiver;
    class_t  *class;
 };
*/
#define CLASS		4
#define RECEIVER 	0

/*
 struct objc_object
 {
    class_t *isa;
 };
*/
#define ISA			0

/*
 struct class_t
 {
    class_t *isa;
    class_t *super_class;
    cache_t *cache;
    ...
 };
*/
#define CACHE		8

/*
 struct cache_t
 {
    uintptr_t  count;
    method_t  *list;
 };
*/
#define COUNT		0
#define LIST		4

/*
 struct objc_message_ref
 {
    id  (*handler)(id,SEL, ...);
    SEL selector;
 };
*/
#define SELECTOR	4

.macro PreCall
	mflr %r0
	stw %r0,4(%r1)
	stwu %r1,-160(%r1)
	stw %r3,8(%r1)
	stw %r4,12(%r1)
	stw %r5,16(%r1)
	stw %r6,20(%r1)
	stw %r7,24(%r1)
	stw %r8,28(%r1)
	stw %r9,32(%r1)
	stw %r10,36(%r1)
	stw %r11,40(%r1)
	stfd %f1,48(%r1)
	stfd %f2,56(%r1)
	stfd %f3,64(%r1)
	stfd %f4,72(%r1)
	stfd %f5,80(%r1)
	stfd %f6,88(%r1)
	stfd %f7,96(%r1)
	stfd %f8,104(%r1)
	stfd %f9,112(%r1)
	stfd %f10,120(%r1)
	stfd %f11,128(%r1)
	stfd %f12,136(%r1)
	stfd %f13,144(%r1)
.endm
.macro PostCall
	lfd %f1,48(%r1)
	lfd %f2,56(%r1)
	lfd %f3,64(%r1)
	lfd %f4,72(%r1)
	lfd %f5,80(%r1)
	lfd %f6,88(%r1)
	lfd %f7,96(%r1)
	lfd %f8,104(%r1)
	lfd %f9,112(%r1)
	lfd %f10,120(%r1)
	lfd %f11,128(%r1)
	lfd %f12,136(%r1)
	lfd %f13,144(%r1)
	lwz %r3,8(%r1)
	lwz %r4,12(%r1)
	lwz %r5,16(%r1)
	lwz %r6,20(%r1)
	lwz %r7,24(%r1)
	lwz %r8,28(%r1)
	lwz %r9,32(%r1)
	lwz %r10,36(%r1)
	lwz %r11,40(%r1)
	addi %r1,%r1,160
	lwz %r0,4(%r1)
	mtlr %r0
.endm

.macro RebuildCache
	PreCall
	lwz %r3,ISA(%r3)
	bl PIC_PLT(objc_init_dispatch_table)
	PostCall
.endm

.macro Cached sel, forward
	lwz %r0,COUNT(%r11)
	cmplw %cr7,\sel,%r0
	bgt- %cr7,\forward
	addi %r12,%r11,4
	lwzx %r11,%r12,\sel
	cmplwi %cr7,%r11,0
	beq- %cr7,\forward
	lwz %r12,8(%r11)
	mtctr %r12
	bctr
.endm

/************************
 * id objc_msgSend(
 *		struct objc_super2 *super,
 *		objc_message_ref *ref
 *		)
*/
ENTRY(objc_msgSend_fixedup)
	lwz %r4,SELECTOR(%r4)
ENTRY(objc_msgSend)
	cmplwi %r3,0
	beq- .L_leave
.L_begin:
	lwz %r12,ISA(%r3)
	lwz %r11, CACHE(%r12)
	cmplwi %cr7,%r11,0
	beq- cr7,.L_load_cache
.L_cached:
	Cached %r4,.L_forward
	
.L_load_cache:
	RebuildCache
	b .L_begin
.L_leave:
	blr

.L_forward:
	b PIC_PLT(objc_msg_forward)

/************************
 * id objc_msgSendSuper2(
 *		struct objc_super2 *super,
 *		objc_message_ref *ref
 *		)
*/
ENTRY(objc_msgSendSuper2_fixedup)
	lwz %r4,SELECTOR(%r4)
ENTRY(objc_msgSendSuper)
	lwz %r12,CLASS(%r3)
	lwz %r3,RECEIVER(%r3)
	lwz %r12,4(%r12)
	lwz %r11, CACHE(%r12)
	cmplwi %cr7,%r11,0
	beq- cr7,.L0_load_cache
.L0_cached:
	Cached %r4,.L_forward
	
.L0_load_cache:
	mr %r11,%r12
	PreCall
	mr %r3,%r11
	bl PIC_PLT(objc_init_dispatch_table)
	PostCall
	lwz %r11,CACHE(%r11)
	b .L0_cached

/************************
 * void objc_msgSendSuper2_stret(
 *		struct ret *ret,
 *		struct objc_super2 *super,
 *		objc_message_ref *ref
 *		)
*/
ENTRY(objc_msgSendSuper2_stret_fixedup)
	lwz %r5,SELECTOR(%r5)
ENTRY(objc_msgSendSuper_stret)
	lwz %r12,CLASS(%r4)
	lwz %r4,RECEIVER(%r4)
	lwz %r12,4(%r12)
	lwz %r11, CACHE(%r12)
	cmplwi %cr7,%r11,0
	beq- cr7,.L2_load_cache
.L2_cached:
	Cached %r5,.L_forward_s
	
.L2_load_cache:
	mr %r11,%r12
	PreCall
	mr %r3,%r11
	bl PIC_PLT(objc_init_dispatch_table)
	PostCall
	lwz %r11,CACHE(%r11)
	b .L2_cached

/************************
 * void objc_msgSend_stret(
 *		struct ret *ret,
 *		struct objc_super2 *super,
 *		objc_message_ref *ref
 *		)
*/
ENTRY(objc_msgSend_stret_fixedup)
	lwz %r5,SELECTOR(%r5)
ENTRY(objc_msgSend_stret)
	cmplwi %r4, 0
	beq- .L_leave
	lwz %r12,ISA(%r4)
	lwz %r11, CACHE(%r12)
	cmplwi %cr7,%r11,0
	beq- cr7,.L1_load_cache
.L1_cached:
	Cached %r5,.L_forward_s
	
.L1_load_cache:
	RebuildCache
	b .L1_cached
.L_forward_s:
	b PIC_PLT(objc_msg_forward_stret)

ENTRY(objc_msgSend_fixup)
	PreCall
	mr %r5, %r4
	li %r4, 0
	bl PIC_PLT(_objc_fixupMessageRef)
	mtctr %r3
	PostCall
	lwz %r4,4(%r4)
	bctr

ENTRY(objc_msgSendSuper2_fixup)
	PreCall
	mr %r5, %r4
	mr %r4, %r3
	lwz %r3, 4(%r4)
	bl PIC_PLT(_objc_fixupMessageRef)
	mtctr %r3
	PostCall
	lwz %r4,4(%r4)
	lwz %r3,0(%r3)
	bctr

ENTRY(objc_msgSend_stret_fixup)
	PreCall
	mr %r3, %r4
	li %r4,0
	bl PIC_PLT(_objc_fixupMessageRef)
	mr %r12,%r3
	mtctr %r3
	PostCall
	lwz %r5,4(%r5)
	bctr

ENTRY(objc_msgSendSuper2_stret_fixup)
	PreCall
	lwz %r3, 4(%r4)
	bl PIC_PLT(_objc_fixupMessageRef)
	mtctr %r3
	PostCall
	lwz %r5,4(%r5)
	lwz %r4,0(%r4)
	bctr
