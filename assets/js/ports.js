import * as AbsintheSocket from '@absinthe/socket';

import { createAbsintheSocket, createPhoenixSocket } from './socket';

/**
 * This module contains utility functions for setting up Elm ports.
 */
const logEvent = (eventName) => (...args) => console.log(eventName, ...args);

/**
 * Attach ports appropriately. `app` is the mounted Elm program.
 */
export function attachPorts(app) {
  const phoenixSocket = createPhoenixSocket();
  const absintheSocket = createAbsintheSocket(phoenixSocket);

  // This port is for pushing a graphql operation to the backend
  app.ports.push.subscribe(({ id, operation, variables }) => {
    const notifier = AbsintheSocket.send(absintheSocket, { operation, variables });
    // we observe what happens and tell the Elm app through
    // some port ports
    AbsintheSocket.observe(absintheSocket, notifier, {
      onStart: (data) => {
        logEvent(`${id} Start`)({ subscriptionId: data.subscriptionId });
        app.ports.socketStart.send(data.subscriptionId || '');
      },
      onResult: (result) => {
        logEvent(`${id} Result`)(result);
        app.ports.socketResult.send({ id, data: JSON.stringify(result.data) });
      },
      onCancel: () => {
        logEvent(`${id} Cancel`)({ subscriptionId: notifier.subscriptionId });
        app.ports.socketCancel.send(notifier.subscriptionId || '');
      },
      onAbort: (error) => {
        logEvent(`${id} Abort`)({ message: error.message });
        app.ports.socketAbort.send(error.message);
      },
      onError: (error) => {
        logEvent(`${id} Error`)({ message: error.message });
        app.ports.socketError.send(error.message);
      },
    });
  });
}
