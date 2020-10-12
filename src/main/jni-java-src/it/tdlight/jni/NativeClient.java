package it.tdlight.jni;
/*
 * Copyright (c) 2018. Ernesto Castellotti <erny.castell@gmail.com>
 * This file is part of JTdlib.
 *
 *     JTdlib is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU Lesser General Public License as published by
 *     the Free Software Foundation, either version 3 of the License.
 *
 *     JTdlib is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU Lesser General Public License
 *     along with JTdlib.  If not, see <http://www.gnu.org/licenses/>.
 */



import it.tdlight.jni.TdApi.Function;
import it.tdlight.jni.TdApi.Object;

public class NativeClient {

    private static native int createNativeClient();

    private static native void nativeClientSend(int nativeClientId, long eventId, TdApi.Function function);

    private static native int nativeClientReceive(int[] clientIds, long[] eventIds, TdApi.Object[] events, double timeout);

    private static native int nativeClientReceive(int[] clientIds, long[] eventIds, TdApi.Object[] events, double timeout, boolean include_responses, boolean include_updates);

    private static native TdApi.Object nativeClientExecute(TdApi.Function function);
}
