/*
 * Copyright (c) 2008	Gold Project
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the Project nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR COEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSObject.h>

/*!
 * \file StateMachine.h
 */
@class State;
@class Invocation;

/*!
 * \brief Transition to another state, with a validation.
 */
@interface StateTransition : NSObject
{
	State *nextState;	/*!< \brief State to transition to. */
	Invocation *validator; /*!< \brief Transition validator. */
	NSString *eventName;	/*!< \brief Event trigger name for this transition. */
}

/*!
 * \brief NSSet up the transition to the given state using the given delegate and
 * selector.
 */
- initWithDelegate:(id)del selector:(SEL)delSel targetState:(State *)next;

/*!
 * \brief NSSet up the transition to the given state using an invocation.
 * \param delInv Invocation for validator.  This allows you to configure the
 * validator however you wish, instead of requiring no arguments.
 * \param next Target state for this transition.
 */
- initWithInvocation:(Invocation *)delInv targetState:(State *)next;

/*!
 * \brief Check if it's valid to transition to the target state for the given
 * state machine.
 * \param stateMachine State machine this transition applies to.
 */
- (bool) canTransition:(StateMachine *)stateMachine;
@end

/*!
 * \brief A state in a state machine.
 */
@interface State : NSObject
{
	NSString *name;			/*!< \brief State name. */
	id delegate;			/*!< \brief Delegate for this state. */
	SEL entryAction;		/*!< \brief Action to perform when entering the state. */
	SEL exitAction;			/*!< \brief Action to perform when leaving the state. */
	NSArray *transitionsOut;	/*!< \brief Valid transitions out of this state. */
	bool isTerminalState;	/*!< \brief Is this a terminal state. */
	bool savesHistory;		/*!< \brief Whether or not to save the previous state for return. */
	State *previousState;	/*!< \brief Used for suspend/resume states. */
	id privateData;			/*!< \brief State-private data. */
}

/*!
 * \brief Initialize the state.
 * \param _name Name of the state.  Must be unique within a given state machine.
 * \param _target Delegate for this state.
 * \param entAct Action to perform at entry.
 * \param exAct Action to perform at exit.
 */
- initWithName:(NSString *)_name delegate:(id)_target entryAction:(SEL)entAct exitAction:(SEL)exAct;

/*!
 * \brief Add an output state, with optional transition guard.
 * \param toState Target output state.
 * \param trans Transition guard.
 */
- (void)addOutputState:(State *)toState transition:(StateTransition *)trans;

/*!
 * \brief NSSet if this is a terminal state or not.
 * \param _isTerminalState \c true if this is to be a valid terminal state.
 */
- (void)setIsTerminalState:(bool)_isTerminalState;

/*!
 * \brief Returns whether the receiver is a valid terminal state.
 */
- (bool)isTerminalState;

/*!
 * \brief Sets the state's private data.
 * \param privData Private data for the state.  The data is retained, not
 * copied, so it can be manipulated as necessary.
 */
- (void)setPrivateData:(id)privData;

/*!
 * \brief Returns the state's private data.
 */
- (id)privateData;

@end

/*!
 \class StateMachine

 A state machine consists of a set of states and transitions.  Each state has a
 name and entry and exit actions, along with zero or more transitions to the
 next state.  Transitions are validated by a delegate 
 */
@interface StateMachine : NSObject
{
	State *initialState;	/*!< \brief Initial state for the state machine. */
	NSSet *states;			/*!< \brief NSSet of valid states in this state machine. */
	State *currentState;	/*!< \brief Current state for this state machine. */
}

/*!
 * \brief Adds a new state to the state machine.
 * \brief newState State to add to the receiver.
 */
- (void)addState:(State *)newState;

/*!
 * \brief Attempt to set the state machine to a new state.
 * \brief newState New state for the receiver.
 * \returns \c true if the new state is valid from transitions, \c false
 * otherwise.
 */
- (bool)setState:(State *)newState;

/*!
 * \brief NSSet the initial state for this state machine.
 * \param startState Starting state.
 */
- (void)setStartState:(State *)startState;

/*!
 * \brief Attempt to set the state machine to a new state.
 * \param newStateName Name of the new state for the receiver.
 * \returns \c true if the new state is valid from transitions, \c false
 * otherwise.
 */
- (bool)setStateNamed:(NSString *)newStateName;

/*!
 * \brief Returns the current state of the receiver.
 */
- (State *)currentState;

/*!
 * \brief Clock the state machine, using the first matching transition to change
 * to the next state.
 */
- (void) transition;

@end

/*
   vim:syntax=objc:
 */
