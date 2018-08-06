import { App } from '../elm/src/App.elm';
import { attachPorts } from './ports';

import '../css/app.css';
import 'phoenix_html';

/* This is the main JS file being loaded by the layout. It sets up the whole
 * frontend: loads css, loads the Elm program, finds the DOM node where to
 * mount it, does the actual mounting, subscribes to the Phoenix socket, wraps

 * that in an Absinthe socket and wires _that_ up to appropriate Elm ports
 * so that the whole thing can start working.
 */

const node = document.getElementById('app');
const app = App.embed(node);
attachPorts(app);
