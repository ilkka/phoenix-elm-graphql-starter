import { App } from '../elm/src/App.elm';

import '../css/app.css';
import 'phoenix_html';

const node = document.getElementById('app');
const app = App.embed(node);
