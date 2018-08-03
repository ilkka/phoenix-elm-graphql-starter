import * as AbsintheSocket from '@absinthe/socket';
import { Socket as PhoenixSocket } from 'phoenix';

import { App } from '../elm/src/App.elm';

import '../css/app.css';
import 'phoenix_html';

const node = document.getElementById('app');
const app = App.embed(node);

app.ports.sendData.subscribe(function(data) {
  console.log(`from elm: ${data}`);
  const now = new Date();
  setTimeout(function() {
    app.ports.receiveData.send(`message received ${now}`);
  }, 1000);
});

const absintheSocket = AbsintheSocket.create(new PhoenixSocket('ws://localhost:4000/socket'));
const operation = `{
  allTasks {
    id
    description
    done
  }
}`;
const notifier = AbsintheSocket.send(absintheSocket, {
  operation,
});
const logEvent = (eventName) => (...args) => console.log(eventName, ...args);
const watchedNotifier = AbsintheSocket.observe(absintheSocket, notifier, {
  onAbort: logEvent('Abort'),
  onError: logEvent('Error'),
  onStart: logEvent('Start'),
  onResult: logEvent('Result'),
});
