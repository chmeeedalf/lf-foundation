/* Copyright (c) 2008 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import "URIProtocol_http.h"
#import <Foundation/URIRequest.h>
#import <Foundation/NSStream.h>
#import <Foundation/RunLoop.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSData.h>
#import <Foundation/NSURI.h>
#import <Foundation/Host.h>
#import <string.h>

enum
{
	STATE_waitingForStatusCR,
	STATE_waitingForStatusLF,
	STATE_waitingForHeader,
	STATE_waitingForContinuationCR,
	STATE_waitingForContinuationLF,
	STATE_waitingForHeaderColon,
	STATE_waitingForSpaceAfterHeaderColon,
	STATE_waitingForHeaderCR,
	STATE_waitingForHeaderLF,
	STATE_waitingForLastLF,
	STATE_waitingForChunkSize,
	STATE_waitingForChunkSizeLF,
	STATE_waitingForChunkCompletion,
	STATE_waitingForChunkCompletionLF,
	STATE_entity_body,
	STATE_done,
};

@implementation URIProtocol_http

-(void)status:(NSString *)status
{
	NSLog(@"status:  [%@]",status);
}

-(void)headers:(NSDictionary *)headers
{
	NSLog(@"headers: %@",headers);
}

-(void)entityChunk:(NSData *)data
{
	//	NSLog(@"entity chunk %@",[[[NSString alloc] initWithData:data encoding:UTF8StringEncoding] autorelease]);
	if ( [data length] )
	{
		[_client URIProtocol:self didLoadData:data];
	}
}

-(void)entity:(NSData *)data
{
	// NSLog(@"entity %@",[[[NSString alloc] initWithData:data encoding:UTF8StringEncoding] autorelease]);
	NSLog(@"will send didLoadData");
	if ( [data length] )
	{
		[_client URIProtocol:self didLoadData:data];
	}
	NSLog(@"did send didLoadData, will send finishLoading");
	[_client URIProtocolDidFinishLoading:self];
}

-(void)_headerKey
{
	[_currentKey autorelease];
	_currentKey=[[NSString alloc] initWithCString:(char*)_bytes+_range.location length:_range.length];
}

-(void)_headerValue
{
	NSString *value=[NSString stringWithCString:(char*)_bytes+_range.location length:_range.length-1];
	NSString *oldValue;

	if((oldValue=[_headers objectForKey:_currentKey])!=nil)
	value=[[oldValue stringByAppendingString:@" "] stringByAppendingString:value];

	[_headers setObject:value forKey:_currentKey];
}

-(void)_continuation
{
	NSString *value=[NSString stringWithCString:(char*)_bytes+_range.location length:_range.length-1];
	NSString *oldValue=[_headers objectForKey:_currentKey];

	value=[[oldValue stringByAppendingString:@" "] stringByAppendingString:value];

	[_headers setObject:value forKey:_currentKey];
}

-(void)_entity
{
	NSLog(@"_entity");
	id data=[NSData dataWithBytes:_bytes+_range.location length:_range.length];
	NSLog(@"_entity  - data with length: %d",[data length]);
	[self entity:data];
	NSLog(@"_entity did send data");

}

-(void)_entityChunk
{
	NSLog(@"_entityChunk");
	[self entityChunk:[NSData dataWithBytes:_bytes+_range.location length:_range.length]];
	_range.location=MaxRange(_range);
	_range.length=0;
	NSLog(@"did pass to entityChunk");
}

-(bool)contentIsChunked
{
	return [[_headers objectForKey:@"Transfer-Encoding"] isEqual:@"chunked"];
}

-(unsigned)contentLength
{
	return [[_headers objectForKey:@"Content-Length"] intValue];
}

-(bool)advanceIsEndOfReply
{
	while(MaxRange(_range)<_length)
	{
		uint8_t code=_bytes[MaxRange(_range)];
		enum 
		{
			extendLength,
			advanceLocationToNext,
			advanceLocationToCurrent,
		} rangeAction=extendLength;

		switch(_state)
		{

			case STATE_waitingForStatusCR:
				if(code=='\015')
					_state=STATE_waitingForStatusLF;
				break;

			case STATE_waitingForStatusLF:
				if(code!='\012')
					_state=STATE_waitingForStatusCR;
				else
				{
					[self status:[NSString stringWithCString:(char*)_bytes+_range.location length:_range.length-1]];
					_state=STATE_waitingForHeader;
					rangeAction=advanceLocationToNext;
				}
				break;

			case STATE_waitingForHeader:
				if(code==' ' || code=='\t')
					_state=STATE_waitingForContinuationCR;
				else if(code=='\015')
					_state=STATE_waitingForLastLF;
				else
					_state=STATE_waitingForHeaderColon;
				break;

			case STATE_waitingForContinuationCR:
				if(code=='\015')
					_state=STATE_waitingForContinuationLF;
				break;

			case STATE_waitingForContinuationLF:
				if(code!='\012')
					_state=STATE_waitingForContinuationCR;
				else
				{
					[self _continuation];
					_state=STATE_waitingForHeader;
					rangeAction=advanceLocationToNext;
				}
				break;

			case STATE_waitingForHeaderColon:
								  if(code==':')
								  {
									  [self _headerKey];
									  _state=STATE_waitingForSpaceAfterHeaderColon;
									  rangeAction=advanceLocationToNext;
								  }
								  break;

			case STATE_waitingForSpaceAfterHeaderColon:
								  if(code==' ')
								  {
									  rangeAction=advanceLocationToNext;
									  break;
								  }
								  _state=STATE_waitingForHeaderCR;
								  // fallthru

			case STATE_waitingForHeaderCR:
								  if(code=='\015')
									  _state=STATE_waitingForHeaderLF;
								  break;

			case STATE_waitingForHeaderLF:
								  if(code!='\012')
									  _state=STATE_waitingForHeaderCR;
								  else
								  {
									  [self _headerValue];
									  _state=STATE_waitingForHeader;
									  rangeAction=advanceLocationToNext;
								  }
								  break;

			case STATE_waitingForLastLF:
						  [self headers:_headers];
						  if([self contentIsChunked])
						  {
							  _state=STATE_waitingForChunkSize;
							  _chunkSize=0;
							  rangeAction=advanceLocationToNext;
							  break;
						  }
						  else if([self contentLength]==0)
						  {
							  _state=STATE_done;
							  return true;
						  }
						  else
						  {
							  _state=STATE_entity_body;
							  rangeAction=advanceLocationToCurrent;
							  NSLog(@"will try to check for extra <lf>");
							  if ( MaxRange(_range)<_length && _bytes[MaxRange(_range)] == '\012' )
							  {
								  NSLog(@"=== advance over trailing <lf> before body === ");
								  _range.length++;
							  }
							  NSLog(@"after <lf> check");
						  }
						  break;

			case STATE_waitingForChunkSize:
						  if(code>='0' && code<='9')
							  _chunkSize=_chunkSize*16+(code-'0');
						  else if(code>='a' && code<='f')
							  _chunkSize=_chunkSize*16+(code-'a')+10;
						  else if(code>='A' && code<='F')
							  _chunkSize=_chunkSize*16+(code-'A')+10;
						  else if(code=='\015')
							  _state=STATE_waitingForChunkSizeLF;
						  else{
							  NSLog(@"parse error %d %o",__LINE__,code);
						  }
						  break;

			case STATE_waitingForChunkSizeLF:
						  if(code=='\012')
						  {
							  if(_chunkSize==0)
							  {
								  _state=STATE_done;
								  return true;
								  NSLog(@"zero chunk");
							  }
							  else
							  {
								  NSLog(@"chunk=%d",_chunkSize);
								  _state=STATE_waitingForChunkCompletion;
								  rangeAction=advanceLocationToNext;
							  }
						  }
						  else
						  {
							  NSLog(@"parse error %d",__LINE__);
						  }
						  break;

			case STATE_waitingForChunkCompletion:
						  if(_range.length==_chunkSize)
						  {
							  _state=STATE_waitingForChunkCompletionLF;
							  _chunkSize=0;
							  if(code=='\015')
								  NSLog(@"got cr");
							  NSLog(@"chunk done");
							  [self _entityChunk];
						  }
						  break;

			case STATE_waitingForChunkCompletionLF:
						  if(code=='\012')
							  NSLog(@"got lf");
						  _state=STATE_waitingForChunkSize;
						  break;

			case STATE_entity_body:
						  if(_range.length>=[self contentLength])
						  {
							  NSLog(@"transfer completed");
							  [self _entity];
							  _state=STATE_done;
							  return true;
						  }
						  break;

			case STATE_done:
						  return true;
		}

		switch(rangeAction)
		{
			case extendLength:
				_range.length++;
				break;

			case advanceLocationToNext:
				_range.location=MaxRange(_range)+1;
				_range.length=0;
				break;

			case advanceLocationToCurrent:
				_range.location=MaxRange(_range);
				_range.length=0;
				break;
		}
	}

	return false;
}

-(void)appendData:(NSData *)data
{
	[_data appendData:data];
	_bytes=[_data bytes];
	_length=[_data length];
	//   NSLog(@"length=%d",_length);
}

-(void)startLoading
{
	_data=[NSMutableData new];
	_range=MakeRange(0,0);
	_headers=[NSMutableDictionary new];
}

-(void)stopLoading
{

}

-(void)inputStream:(NSInputStream *)stream handleEvent:(StreamEvent)streamEvent 
{
	uint8_t buffer[1024];
	long size=[stream read:buffer maxLength:sizeof(buffer)];
	//	NSLog(@"stream event: %d bytes read: %d",streamEvent,size);
	if (size>0)
	{
		[self appendData:[NSData dataWithBytes:buffer length:size]];
		if ([self advanceIsEndOfReply])
		{
			NSLog(@"done");
			//			[_client URIProtocol:self didLoadData:[NSData dataWithBytes:buffer length:size] ];
			//			[_client URIProtocolDidFinishLoading:self];
		}
		else
		{
			//			NSLog(@"not done yet");
			//[_client URIProtocol:didLoadData:];
			//			[_client URIProtocolDidFinishLoading:self];
		}
	} else
	{
		if ( streamEvent == 16 )
		{
			[self _entity];
			//			[_client URIProtocolDidFinishLoading:self];
			[self stopLoading];
		}
	}


}

-(void)outputStream:(NSOutputStream *)stream handleEvent:(StreamEvent)streamEvent 
{
	if(streamEvent==StreamEventHasSpaceAvailable && !sentrequest)
	{
		NSURI* url=[_request NSURI];
		NSLog(@"will get path");
		NSString* path=[url relativePath];
		if ( [[url query] length] )
		{
			path=[NSString stringWithFormat:@"%@?%@",path,[url query]];
		}


		NSString* host=[url host];
		NSMutableString* httprequest=[NSMutableString string];
		[httprequest appendFormat:@"GET %@ HTTP/1.1\r\n",path];
		[httprequest appendFormat:@"Host: %@\r\n",host];
		[httprequest appendFormat:@"Accept: */*\r\n"];
		[httprequest appendFormat:@"User-Agent: Cocotron\r\n"];
		[httprequest appendString:@"\r\n"];
		NSLog(@"request %@ ",httprequest);
		const char* crequest=[httprequest UTF8String];
		[stream write:(uint8_t *)crequest maxLength:strlen(crequest)];
		sentrequest=true;

	}

}

-(void)stream:(NSStream *)stream handleEvent:(StreamEvent)streamEvent
{
	if([stream isKindOfClass:[NSInputStream class]])
		   [self inputStream:(NSInputStream *)stream handleEvent:streamEvent];
	else if([stream isKindOfClass:[NSOutputStream class]])
			   [self outputStream:(NSOutputStream *)stream handleEvent:streamEvent];
}

+(bool)canInitWithRequest:(URIRequest *)request
{
	if( [[[request NSURI]scheme] isEqual:@"http"]) return true;
	return 0;
}
-initWithRequest:(URIRequest *)request cachedResponse:(CachedURIResponse *)response client:(id <URIProtocolClient>)client
{
	_request=[request retain];
	_response=[response retain];
	_client=[(id)client retain];
	sentrequest=false;
	return self;
}

@end
