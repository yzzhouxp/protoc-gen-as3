// vim: tabstop=4 shiftwidth=4

// Copyright (c) 2010 , NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.protobuf {
	import flash.errors.IllegalOperationError;
	import flash.utils.IDataInput
	public class FieldDescriptor extends BaseFieldDescriptor {
		override public final function read(input:IDataInput,
				message:Message, tag:uint):void {
			message[this] = readSingleField(input)
		}
		override public final function write(output:WritingBuffer,
				message:Message):void {
			WriteUtils.write$TYPE_UINT32(output, tag)
			writeSingleField(output, message[this])
		}
	}
}
