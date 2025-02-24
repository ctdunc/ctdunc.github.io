# Making Clientside Callbacks Nicer in Dash
##### Connor Duncan, 01/09/2025

Be sure to check out the sequels to this post, where I 
explain how to install this as a plugin ([part two](./dash-clientside-treesitter-ez-mode.html)), and how to get Language Server features
like code completion and show definition working in clientside callbacks ([part three](./dash-clientside-lsp.html)).

## Why Clientside Callbacks?
I work on a fairly large [Plotly `Dash`](https://dash.plotly.com/) app in my day job, which contains
many inputs that require validation.
One of the downsides of Dash is that under their "expected" pattern of use, this sort of input validation
should happen on the server. 
If you want to build an app that doesn't require network calls and annoying 
delays to determine whether a text field input matches a regex, you need a way to do this
sort of thing in the browser, which is why Dash introduced [`clientside_callback`](https://dash.plotly.com/clientside-callbacks).

## What's the problem?
These work pretty well once you're done writing them, but writing them is an absolute _drag_, since 
they are kept as Strings in your Python code. 
Below is an example of a clientside callback which takes the `value` output of a [`TagsInput`](https://www.dash-mantine-components.com/components/tagsinput)
and ensures that all inputs can be parsed according to some custom business logic
`parseFloatMConvention`.
If they can't be parsed, they are output to the components `error` property, which prompts
the user to correct their mistake.

<img src="/res/img/dash-clientside-nts.png" alt="Dash Clientside Callback No Highlight"/>

Writing JS like this is not too bad for smaller/simpler, functions
but once things get much longer, this begins to suck big time.
Dash does [provide a way](https://dash.plotly.com/external-resources) to keep complex JavaScript in separate files,
but when a function is only used once, this quickly becomes a nuisance as well, since oftentimes you will end up with
functions of the form

    clientside_callback(
      """
      function do_business_thing(a, b, c, d, e, f) {
          return do_business_thing_declared_elsewhere(a, b, c, d, e, f);
      }
      """,
      Input("a", "prop"),
      Input("b", "prop"),
      Input("c", "prop"),
      Input("d", "prop"),
      Input("e", "prop"),
      Input("f", "prop"),
      Output("out", "prop")
    )

This is also not great, since now you need to keep at least two files open to develop logic that only
ever takes place at this location. Plus, you have to keep the signatures of 
`do_business_thing` and `do_business_thing_declared_elsewhere` in sync, which isn't too bad on its own,
but is annoying when you have hundreds of these declarations floating around.

## Enter `treesitter`
Over the last year, I have made the switch from `vim` to `neovim` ([dotfile](https://github.com/ctdunc/dotfiles) plug),
which has been very good to me so far.
One of the really cool things about `neovim` is [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter),
which lets you do all kinds of fancy things with the syntax tree seen by your editor.
I won't pretend to be a `treesitter` expert, but when I discovered [language injections](https://tree-sitter.github.io/tree-sitter/3-syntax-highlighting.html)
I immediately had my first application: fixing Dash Clientside Callbacks!

Armed with [this video](https://www.youtube.com/watch?v=09-9LltqWLY) from TJ DeVries (a `neovim` GOAT), and the commands 
`:InspectTree` and `:EditQuery`, I was able to hack together the following injection:

    ;extends
    ; look for calls to functions named clientside_callback
    (call 
      (identifier) @name (#eq? @name clientside_callback) 
      (argument_list 
	; if the first argument is a string, 
	; set the language of the child string_content to javascript
	((string (string_content) 
		 @injection.content 
		 (#set! injection.include-children)
		 (#set! injection.language "javascript")))
	    )
    )

Placing this injection at `$NVIM_CONFIG_LOCATION/queries/python/injections.scm` resulted in 
good-enough JavaScript syntax highlighting in python files! Behold:

<img src="/res/img/dash-clientside-ts.png" alt="Dash Clientside Callback Highlighted"/>

This wasn't overly complicated. Between watching TJ's video and figuring out the Scheme syntax,
it took about an hour, and has been a giant quality of life boost for me, and resulted in
big performance improvements to our Dash tool at work.


## And to my VS Code Enjoyers...
Something like this might be possible for VS Code users as well. There are quite a few 
`treesitter` [plugins](https://marketplace.visualstudio.com/search?term=tree%20sitter&target=VSCode&category=All%20categories&sortBy=Relevance)
at least [one](https://marketplace.visualstudio.com/items?itemName=AlecGhost.tree-sitter-vscode) 
of which appears to support injections. This seems like a productive direction to explore. Feel free to
reach out if you do get it working, I'll update this post. 

Looking through the Dash forums, I am not the first person to encounter or solve this issue.
For example, user StevenAllenKing wrote a VS Code extension that uses inline comments to handle
the syntax injection. Check it out [here](https://community.plotly.com/t/show-and-tell-clientside-callback-javascript-syntax-highlighting-in-python-multi-line-strings/56663).
I still think my approach has a few advantages: it is editor agnostic (as long as `treesitter` 
support exists), and works for functions declared on a single line as well (nice for 
nullish coalescing and the like). Plus, you don't have to have all those extra comments
lying around!

## Update 01/22/2025
See [part 2](./dash-clientside-treesitter-ez-mode.html) for an easier way to install this capability!
