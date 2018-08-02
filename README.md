# Phoenix + GraphQL + Elm starter kit

So I listened to [an episode of Fullstack Radio](http://www.fullstackradio.com/91) where Derrick Reimer talks about [level.app](https://level.app/), a new team communication platform he's building out in the open, and got mightily inspired. He is using what I would call my "unicorn stack", Elixir + Phoenix + GraphQL + Elm. I peeked into the source and really liked how Level is set up, so I decided to try to build a similar basic project structure from scratch, for my own amusement. This is it, or will be it, or should have been it maybe, depending on where you are in the multiverse.

Level looks really slick and sounds like a fantastic idea, and I'm really grateful to Derrick for deciding to release it as open source for the rest of us software professionals and hobbyists to learn from.

## How does it work?

Here's how it's put together:

1.  Using Elixir 1.7.1 built with Erlang 21, generated a Phoenix app with `--no-brunch` since I knew I was gonna use webpack instead.
1.  Bootstrapped a JavaScript project in `assets` by just creating a blank `package.json` and installing the deps, see `package.json`. Standard Webpack fare, plus some runtime deps for Absinthe (for GraphQL) and a couple of Phoenix things (the `file` URLs). Note that a beta version of `extract-text-webpack-plugin` has to be used with Webpack 4.
1.  Added a watcher in `config/dev.exs` for building the frontend with Webpack.
1.  Configured Webpack in `assets/webpack.config.js`, thankfully quite a simple config aped verbatim from Level.
1.  Ditto `assets/postcss.config.js`.
1.  Added a wholly default config for tailwindcss in `assets/tailwind.js`.
1.  Ripped out most stuff from `lib/phelmx_web/templates/layout/app.html.eex` and `lib/phelmx_web/templates/page/index.html.eex`, and replaced with just rendering a single target `div` for the Elm app.
1.  Created a maximally simple increment / decrement counter Elm program in `assets/elm`, the program source file is `assets/elm/src/App.elm`.
1.  Added the JS entrypoint in `assets/js/app.js` that imports the Elm program (through Webpack) and embeds it in the target `div`. The JS entrypoint is loaded in the `app.html.eex` tmeplate.

This gets us to the point where the counter app loads in the browser, but doesn't yet talk to the backend. Rebuilds work as you would think, not sure about HMR yet.

## Using it

Well I guess you gotta search-and-replace the thankfully probably easy to spot "phelmx" and its CamelCased variants with whatever you want for yourself.

## Running it

TODO:

- bootstrapping the frontend
  - install deps
  - rembember that yarn kinda doesn't work on win? the binaries go in the wrong place?

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Start up the DB container with `docker-compose up -d db`
- Create and migrate your database with `mix ecto.create && mix ecto.migrate`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Attribution

Parts of the tooling, notably the Webpack and postcss configurations come directly from Level, and the entire way the project is set up mimics it. They are used under the terms of their Apache License version 2.0.
