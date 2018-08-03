/**
 * This module contains utility functions for setting up phoenix and
 * absinthe sockets.
 */
import * as AbsintheSocket from '@absinthe/socket';
import { Socket as PhoenixSocket } from 'phoenix';

const ENDPOINT = `ws://${window.location.host}/socket`;

export function createPhoenixSocket() {
  return new PhoenixSocket(ENDPOINT);
}

export function createAbsintheSocket(phoenixSocket) {
  return AbsintheSocket.create(phoenixSocket);
}
