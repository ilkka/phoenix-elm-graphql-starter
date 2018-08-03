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
