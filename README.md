# Phelmx

So I listened to [an episode of Fullstack Radio](http://www.fullstackradio.com/91) where Derrick Reimer talks about [level.app](https://level.app/), a new team communication platform he's building out in the open, and got mightily inspired. He is using what I would call my "unicorn stack", Elixir + Phoenix + GraphQL + Elm. I peeked into the source and really liked how Level is set up, so I decided to try to build a similar basic project structure from scratch, for my own amusement. This is it, or will be it, or should have been it maybe, depending on where you are in the multiverse.

## Using it

Well I guess you gotta search-and-replace the thankfully probably easy to spot "phelmx" and its CamelCased variants with whatever you want for yourself.

## Running it

TODO:

- bootstrapping the frontend
  - install deps
  - rembember that yarn kinda doesn't work on win? the binaries go in the wrong place?

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.create && mix ecto.migrate`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

- Official website: http://www.phoenixframework.org/
- Guides: http://phoenixframework.org/docs/overview
- Docs: https://hexdocs.pm/phoenix
- Mailing list: http://groups.google.com/group/phoenix-talk
- Source: https://github.com/phoenixframework/phoenix
