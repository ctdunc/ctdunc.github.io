---
title: Connor Duncan - Home
copyright: Copyright 2026, Connor Duncan
noblog: 1
---

<div style="display: flex; max-width: 100%; justify-content: space-around; flex-wrap: wrap; width: 100%;">
<div style="flex-grow: 1; max-height: 20em; text-align: center; margin: 1em; width: calc(0.3 * var(--max-width));">
<img src="../static/res/profile.jpg" alt="a picture of me" style="height: 100%;"/>
</div>
<div style="flex-grow: 1; max-height: 20em; margin: 1em; width: max(25em, calc(0.3 * var(--max-width)));">
<b is-="badge" variant-="background1"> Connor Duncan </b>
<p is-="badge" variant-="background2"> Quantitative Analyst </p>
<ul marker-="tree">
  <li>
    <a href="/static/res/resume.pdf">resume</a>
  </li>
  <li>
    <a href="blog/index.html">blog</a>
  </li>
  <li>
    <a href="https://github.com/ctdunc">github</a>
  </li>
  <li>
    <a href="https://linkedin.com/in/connortduncan">linkedin</a>
  </li>
  <li>
    <a href="mailto:connor@connorduncan.xyz" id="mail">
      connor@connorduncan.xyz
    </a>
  </li>
</ul>

</div>
</div>

<details open="true" box-="square">
<summary>About Me</summary>
<p>
I am a Quantitative Analyst on the Fixed Income ETF Portfolio Management desk at Invesco.
Before becoming a Quant, I completed a Master's in Applied Mathematics at the
University of Illinois in Chicago, focusing primarily on Numerical Partial Differential Equations.
Even longer ago, I attended the
University of California, Berkeley, where I studied Applied Math
and Physics.
</p><p>
I like working on problems in Optimization (especially Mixed-Integer Programming), PDEs and Data Science.
I also believe the title "Quant" isn't an excuse to leave everything in a Jupyter notebook, and consequently
spend a good chunk of time configuring my development environment to find bugs as I write them.
</p>
</details>

<details open="true" box-="square">
<summary>Side Projects</summary>
<p>
  I work on a few opensource projects in my spare time. The use cases are relatively niche, but if you
  maintain a static blog, need to do security identifier validation in Polars, or want some simple
  scripts for a tmux/suckless Linux setup, you might be interested!
</p>
<details box-="round" id="box-mild">
  <summary>
    <a href="https://github.com/ctdunc/mordant">mordant</a> (static markdown syntax highlighter)
  </summary>
  Actually static syntax highlighting for markdown code blocks, with support for language injections!
  <i>Zero javascript required</i>, just bring your own stylesheet (<a href="./code.css">or use mine</a>). 
  Written in Rust, still very early stages. You can check out a demonstration of the results
  <a href="./blog/dash-clientside-lsp.html">on my blog.</a>
</details>
<details box-="round" id="box-mild">
  <summary>
    <a href="https://github.com/abstractqqq/polars_istr">polars_istr</a> (sec id validation in polars)
  </summary>
  <p>
    String validations in Polars, implemented in Rust.
    I wrote the part that deals with security ID validation. I've found it useful for dealing
    with poorly formatted data where security identifiers are mixed in one column (e.g. splitting out a CUSIP/SEDOL) column
    for use in a join with a properly structured data source).
  </p>
</details>
<details box-="round" id="box-mild">
  <summary>
    <a href="https://github.com/ctdunc/dotfiles">my dotfiles</a> (neovim/tmux/arch linux setup)
  </summary>
  neovim/tmux config, with nice zsh defaults.
  Configured primarly for Python (ruff/pyright) and Rust development (rust-analyzer).
</details>
<details box-="round" id="box-mild">
  <summary>
    <a href="https://github.com/ctdunc/webring">webring</a> (very barebones webring in Rust)
  </summary>
  <p>
      Spin up a webring in 2 minutes. TOML-configured, there are basically no features by design.
      I'll make it multi-threaded if I think people are reading my (or anyone elses) blog.
  </p>
</details>
</details>
<details box-="square">
<summary>Lecture Notes (Math + Physics)</summary>
<p>
  Here are some lecture notes I took as an undergraduate at Cal. These 
  are provided as-is with zero-editing (except PDEs II), and are probably not a great primary
  source if you're in any of these classes. 
  These are mostly here for my own reference, and because they include 
  some nice TiKz pictures.
</p>
<ul marker-="tree">
  <li>
    <a href="/static/notes/math222b.pdf">Partial Differential Equations II (Sung-Jin Oh, Spring 2022)</a>
  </li>
  <li><a href="/static/notes/math104.pdf">Metric Differential Geometry (Rui Wang, Spring 2020)</a></li>
  <li><a href="/static/notes/math185.pdf">Complex Analysis (Peter Koroteev, Spring 2020)</a></li>
  <li><a href="/static/notes/math104.pdf">Real Analysis (Rui Wang, Fall 2019)</a></li>
  <li><a href="/static/notes/physics137b.pdf">Quantum Mechanics II (Ehud Altman, Fall 2019)</a></li>
  <li><a href="/static/notes/physics105.pdf">Analytic Mechanics (Stuart Bale, Fall 2019)</a></li>
</ul>
</details>
<details box-="square">
<summary>/etc</summary>
<p>
    Other random things you might want to look at, or scrape into LLM training data.
</p>
<ul marker-="tree">
  <li><a href="/gainz.html">what I did at the gym on any day since January 1, 2026</a></li>
  <li><a href="https://github.com/ctdunc/ctdunc.github.io">the source code for this website</a></li>
</ul>
</details>
