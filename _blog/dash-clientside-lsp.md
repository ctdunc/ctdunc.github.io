# Enabling LSP Support for Dash Clientside Callbacks
##### Connor Duncan, 02/23/25
##### parts [one](./dash-clientside-treesitter.html) and [two](./dash-clientside-treesitter-ez-mode.html)

- [Why Even Bother?](#why-even-bother)
- [What Will We Cover?](#what-will-we-cover)
- [Setting Up tsc for Dash](#setting-up-tsc-for-dash)
  - [Installation](#installation)
  - [Configuring tsc](#configuring-tsc)
  - [Creating and Emitting Declarations](#creating-and-emitting-declarations)
- [Inline LSP Support in neovim](#inline-lsp-support-in-neovim)
  - [Using TreeSitter Injections with Dash](#using-treesitter-injections-with-dash)
  - [Formatting Clientside Callbacks with prettier](#formatting-clientside-callbacks-with-prettier)
  - [Getting ts_ls Working with otter.nvim](#getting-ts_ls-working-with-otternvim)
- [Wrapping up](#wrapping-up)


If you stick with me through this post, here is the setup we will arrive at.

<img src="/res/img/dash-inline-lsp.gif" alt="GIF showing inline formatting"/>

NOTE: You do not need to be a neovim user to benefit from this post. Many of the tips covered below
apply equally well to any editor that can take advantage of a JavaScript Language Server.

The code demonstrated in this post is available as a sample Dash project on [Github](https://github.com/ctdunc/dash-clientside-lsp-demo).
Everything outside of the [neovim injection](#inline-lsp-support-in-neovim) section assumes that you already have a 
JavaScript LSP installed and configured for your preferred editor.
For neovim, I use [ts_ls](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ts_ls).
For VS C*de, I would bet (some) money that Microsoft's implementation is installed the moment you open a 
TypeScript file, or at least that there is a clippy popup along the lines of 
"Hey there! It looks like you're trying to edit a TypeScript file! Would you like some help with that?"
Anyways, [here are the docs](https://code.visualstudio.com/Docs/languages/typescript) just in case.
For other editors, you're own your own, cowboy.

## Why Even Bother?
If you work with Plotly's [Dash](https://dash.plotly.com) framework, you've probably noticed 
that clientside callbacks are treated somewhat as second-class citizens when it comes
to developer tooling. You've also likely used (or at least encountered)
[`dash_ag_grid`](https://dash.plotly.com/dash-ag-grid). 
`dash-ag-grid` adds support for a limited subset of [Ag Grid](https://www.ag-grid.com/)'s functionality via properties in the usual Dash 
callback manner. If you are inclined to get fancy with your tables, you will need to make use of `dash_ag_grid.getApi`,
as demonstrated by this example more-or-less [stolen from the forums](https://community.plotly.com/t/dash-ag-grid-event-listeners-v-31-2/84848):

```
gridid = "grid"
app.clientside_callback(
    """
(id) => {
  dash_ag_grid.getApiAsync(id).then((api) => {
    api.addEventListener("cellFocused", (params) => {
      console.log(params);
    });
  });
  return dash_clientside.no_update;
};
    """,
    Output(gridid, "id"),
    Input(gridid, "id"),
)
```
With this `api` object in hand, the developer is now empowered to do just about anything their heart desires to 
the Grid. This pattern introduces a few major frustrations:

1. There is no type checking in `clientside_callbacks`. This is fine for simple stuff, but when working 
with complex Grid APIs, such checks are very useful.
2. There is no code completion. The `Ag Grid` API is large and well-documented. This also means that 
searching the docs for your exact use case can take time. If you know what you want to do, but can't remember
the _exact_ name of the function you're looking for, having a searchable index of the `GridApi` at your 
fingertips dramatically increases development speed and enjoyability.
3. You can't lint or format your JS automatically.
4. There is no go to definition, variable renaming, or anything else that LSPs do well.

You _can_ fix some of these issues by including JavaScript in `assets/**.js`, and using your preferred JavaScript LSP as usual.
As I have discussed before, however, I find that for functions that will only ever be called 
from one location, the cognitive overhead of needing to keep track of two very distant locations in 
the file tree for what should be local behavior outweighs any benefit you gain 
in terms of tooling. Especially now that this post exists :). Plus, it should be possible (I am still working this out)
to get jumping to definition working for members of `dagfuncs`, for example, which would
also lighten this load.


## What Will We Cover?
In the rest of this post, I will assume absolutely zero prior JavaScript tooling experience (I didn't have much when I
set out to figure this out), and explain:

1. How to set up [tsc](https://www.typescriptlang.org/docs/handbook/compiler-options.html)
to correctly recognize and generate completions for various Dash-isms and imports that are assumed to be globally available.
2. How to configure neovim to correctly recognize inline JS, and expose JavaScript language server capabilities from within Python.

## Setting Up tsc for Dash
### Installation
First, you will need to install [`npm`](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) and [tsc](https://www.typescriptlang.org/docs/handbook/compiler-options.html). 
If you're on Linux, you can install both through your package manager (e.g. for [Arch Linux](https://archlinux.org/packages/extra/any/typescript/) (btw)).
Node officially recommends using a version manager, so if you're inclined, you can do that as well.
If you're on MacOS or Windows, follow the instructions on the npm website, and use `$ npm install -g tsc` to get TSC installed.
This part is very dependent on your specific operating system and project requirements, so it is likely
worth your time to take a few minutes to read through the linked `npm` page and consider which method
is most appropriate for you.

Next, in the root directory of your project, install `ag-grid-enterprise@31.2.1`, `prettier` and `typescript` as dev dependencies
with the following command:
```
$ npm install --save-dev ag-grid-enterprise@31.2.1 prettier typescript
```
We need the pinned version of `Ag Grid`, since that is what [Dash Ag Grid is currently pinned to](https://dash.plotly.com/dash-ag-grid?trk=public_post_comment-text).
If they get around to updating the Dash Ag Grid dependency, you should use that one instead.

### Configuring tsc
Next, in our project root directory, we need to create a `tsconfig.json` file. 
For more information, check out [the full documentation](https://www.typescriptlang.org/docs/handbook/tsconfig-json.html).
For our use case, I've found that the following configuration tends to work pretty well.

```
{
  "compilerOptions": {
    "alwaysStrict": true,
    "noImplicitReturns": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "outDir": "dist",
    "removeComments": true,
    "inlineSourceMap": true,
    "importHelpers": true,
    "target": "ESNext",
    "module": "commonjs",
    "allowJs": true,
    "checkJs": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "moduleResolution": "node",
    "declaration": true,
    "emitDeclarationOnly": true,
    "declarationMap": true,
    "noImplicitAny": false,
  },
  "exclude": ["node_modules", "env", ".venv", "dist"]
}
```

A few key options that are worth noting here:

- `outDir` should be set to something you aren't already using. If you have an existing `dist` folder, pick something else.
I also like to put this in `.gitignore` since it's basically just a bunch of metadata, and doesn't contain useful info about your
program.
- `exclude` needs to contain `node_modules`, the value of `outDir` (in our case `dist`), and the path to your virtual environment (since
Dash packages contain lots of JS files).
- `declaration` and `declarationMap` must be `true` in order for the next step in this guide to work. Otherwise, our `*.d.ts` files will
not produce useful information for our LSP when using features like go to definition.
- `emitDeclarationOnly` should be `true`, since we don't care about actually emitting JavaScript. Dash handles that for us.
- `noImplicitAny: false` is more a matter of personal preference. If you are using an LSP with `clientside_callback`, I would 
recommend keeping this as `false`, as you cannot use JSDoc comments in clientside callbacks (since Dash would try to assign the comment to a variable otherwise).
- `allowJs` and `checkJs` should both be `true`, otherwise nothing will work outside of any TypeScript you have lying around.

The rest of these I _think_ are a matter of preference, but I haven't tested this very extensively. 
Feel free to [leave an issue](https://github.com/ctdunc/ctdunc.github.io/issues) if I'm wrong.

### Creating and Emitting Declarations
Now, we need to declare the existence of some globally available functions, since any language servers available to 
us don't know about Dash without being told. We can accomplish this by using a [TypeScript declaration file](https://www.typescriptlang.org/docs/handbook/declaration-files/templates/module-d-ts.html).
The file that I use for working with Dash Ag Grid is very simple.
Simply place the following in `assets/index.d.ts`:

```
import { GridApi, } from "ag-grid-enterprise";

declare global {
  namespace dash_ag_grid {
    export function getApi(s: String | Object): GridApi;
    export function getApiAsync(s: String | Object): Promise<GridApi>;
  }
  namespace dash_clientside {
    export const no_update: Object;
  }
  namespace AgGrid {
    export * from "ag-grid-enterprise";
  }
}
```

- Wrapping everything in a `declare global` block makes these namespaces available globally.
- The `dash_ag_grid` namespace allows us to use the event listener pattern mentioned at the beginning
of this article with no hassle.
- The `dash_clientside` namespace exists solely to prevent functions returning a `no_update` from showing errors.
- The `AgGrid` namespace allows us to use `AgGrid.*` in JSDoc Comments, which we will cover in the next section.

Finally, once we have our declaration in `assets/`, run `$ tsc` in the root of your Dash project.
If you already have a JavaScript LSP installed, you should now be able to accomplish something like the following: 

<img src="/res/img/grid-jsdoc.png" alt="A Working LSP Setup!"/>

Note the presence of [JSDoc](https://jsdoc.app/) comments denoting the types of arguments our function is equipped to 
accept. We cannot use type hints the same way that we can in Python, as that feature is TypeScript-only and Dash only accepts vanilla JS (afaik).
Still, this is a great start! I am still playing around with the declarations and what is/isn't necessary. Any changes I 
discover will likely be posted to [the demo repository](https://github.com/ctdunc/dash-clientside-lsp-demo), so
make sure to keep an eye out there. Similarly, if you find any other declarations
useful, please [submit an issue](https://github.com/ctdunc/dash-clientside-lsp-demo/issues) so that I
can update this post and the demo repository!

## Inline LSP Support in neovim
For the eight developers who are working on large-scale Dash applications in neovim, this section is for you.
My configuration can be found [on github](https://github.com/ctdunc/dotfiles/tree/otter/nvim/.config/nvim).
The relevant files are `lua/plugins/conform.lua`, `lua/plugins/dash.lua`, `lua/plugins/lsp.lua`, and `lua/plugins/otter.lua`.
I will explain: 

1. How I use TreeSitter injections to get neovim to recognize inline JavaScript.
2. How I got `prettier` to run correctly on your `clientside_callbacks` using [`conform.nvim`](https://github.com/stevearc/conform.nvim).
3. How I use `ts_ls` with [`otter.nvim`](https://github.com/jmbuhr/otter.nvim) to correctly map language servers to 
code blocks as delineated by `treesitter`. 

The `otter` bit is still a bit buggy, so I have yet to include this feature in [`nvim-dash`](https://github.com/ctdunc/nvim-dash). Once 
I (or someone else) fixes the issue linked to [this pr](https://github.com/jmbuhr/otter.nvim/pull/198), we will be *so back*!

### Using TreeSitter Injections with Dash
I wrote [a whole post](https://www.connorduncan.xyz/blog/dash-clientside-treesitter.html) about getting this working, so give that a read.
I maintain an updated and expanding `injections.scm` file in a [neovim plugin](https://github.com/ctdunc/nvim-dash).
You can install it with your preferred package manager with `ctdunc/nvim-dash`.
Alternately, just copy the [`injections`](https://github.com/ctdunc/nvim-dash/blob/master/queries/python/injections.scm) into your 
`queries/python/injections.scm`.

### Formatting Clientside Callbacks with prettier
For all of my formatting needs, I use `conform.nvim`.
In my config, I have `lua/plugins/conform.lua`, which should contain at a minumum:

```
return {
  {
    "stevearc/conform.nvim",
    opts = {
      -- if you use f-strings, this will save you lots of hassle, 
      -- as the javascript grammar gets very confused by them.
      notify_on_error = false,
      -- you don't need this, but I like to format on save. Muscle memory I guess.
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 1000,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        python = { "injected" },
        javascript = { "prettier" },
        injected = { ignore_errors = true },
      },
    },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      -- vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
```

For `python`, you should probably put your preferred formatter in front of `injected`, otherwise, the _only_
code that conform will format is the inline JavaScript. I use `python = { "ruff_format", "ruff_fix", "injected" }` because 
ruff is wicked fast.

If you've followed my explanation so far, your editor should now be capable of something like this (note that `otter` is _not_ enabled here):

<img src="/res/img/dash-inline-format.gif" alt="GIF showing inline formatting"/>

### Getting ts_ls Working with otter.nvim
Now that we have formatting working fairly well, it's time to get autocomplete working on our embedded JavaScript.
For this, we turn to a plugin called [`otter.nvim`]. Before discussing setup, a few things to note:

First, `otter` works more or less by passing the captured ranges of `injection.content` to a hidden buffer, and then
passing the output of the LSP attached to that hidden buffer back to the current buffer.
This means that each separate capture must be syntactically valid in the injected language, so even though 
callbacks of the form 

```
function(x) {
  // do stuff to x ...
  return x;
}
```

evaluate to valid JavaScript once Dash gets ahold of them, they are not syntactically valid,
since the function keyword expects a name for the declaration.
This means that we must instead declare functions using arrow syntax, like so:

```
(x) => {
  // do stuff to x ...
  return x;
}
```

It's too bad that the Dash documentation exclusively uses the former syntax, but it is what it is.

Second, `otter` has some weird behavior surrounding whitespace and indentation, and there are some 
[outstanding issues](https://github.com/jmbuhr/otter.nvim/issues/180) that may affect your experience with this plugin.
We're working on it though! For that reason, I have pinned my `otter` version to the fix branch
for this issue, since it seems to work more consistently. Still not consistently enough to merge into master though.
Anyways, the configuration that I use is in `lua/plugins/otter.lua`: 

```
return {
  "jmbuhr/otter.nvim",
  commit = "be6324e0987c4fab347784e602c00f17c5fc0bd7",
  -- dir = "~/code/otter.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    buffers = {
      set_filetype = true,
      write_to_disk = true,
    },
  },
}
```

You can probably get away without my `opts` here, but I have them set to aid in debugging.
Sometimes you'll leave `filename.py.otter.js` files if things fail ungracefully, so be sure to clean those
up from your version control, or just disable writing to disk.
If I've explained this well enough, you should now have something like the following working:

<img src="/res/img/dash-inline-lsp.gif" alt="GIF showing inline formatting"/>

## Wrapping up
That's pretty much it! This has been a large quality of life boost for me at work, as I work on
custom row dragging logic for a table using Tree Data in a Dash app.
If you find this helpful or have any suggestions for ways that I can improve this setup, please feel free
to hit me up on any of my socials ([github](https://github.com/ctdunc), [linkedin](https://www.linkedin.com/in/connortduncan/), [twitter](https://x.com/_ctdunc)),
or just email me (it's on my homepage).
