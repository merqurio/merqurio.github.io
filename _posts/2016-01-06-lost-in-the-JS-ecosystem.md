---
title: Lost in the Javascript ecosystem
date: 2016-01-06 00:00:00 Z
layout: post
---

I want to create an app. Keep it simple. Web looks nice, simple; it's just some
HTML, CSS and JS or isn't it ?

We are working in a new project for which we decided that the web was the
technology to go with in order to be able to successfully support a wide
variety of platforms (Like [Electron][1] for the Desktop and [Phonegap][2] or
[Nativescript][3] for mobiles). After months of research we are even more lost
than at the beginning.


### ES5, ES6+babel, Typescript ? Dart, CoffeeScript ?  There is a nice variety
of supersets of JS in order to make easier programming for the front-end. Some
years ago I learnt ES5, which is ok, but I must admit that I never enjoyed it.
Looking to the future look promising but, which future ?

ES6 looks like it's around the corner, but we must compile it to ES5 nowadays,
there are great transpilers for that, but as soon as we need them, we need a
build system; Grunt, gulp or whatever. Same for Typescript, Dart, CoffeeScript.

Ok, I wanted to write an app. Now I need the HTML, CSS, build system, and JS.

> We are no experts, let's not reinvent the wheel

Coming from Python, one of the first thing I always do when I start a project
is an intense research on GitHub / Google / Stack Overflow to use what other
have already done and that will help me on getting my work done faster and
better.

### Choosing a Framework

> Let's open the Pandora box.

The number of frameworks / libraries to work in a Javascript application is
huge, the solutions diverse and the communities divided and with lot of hate
from ones to each other. Not cool.

Angular(1 & 2), Ember, React, vue.js, Backbone, Polymer etc.. They all look
great, they all have different philosophies and resolve complementary problems
but for a new comer choosing one can be a tedious task. The number of articles
in hackernews comparing them, it's surprising, and it's amazing how many
questions you can find asking for the best of them.

Let's say we choose one. Easily the number of dependencies our app has, meets
enough of them to start thinking in dependency manager like bower or npm or
jpms.

> Is that all ?

Now we have, a build system, the HTML, the JS, the dependency manager and Oh
the CSS, well, that if you live en era where CSS was enough, let's add another
build step with SCSS, because it's easier to write it than css right ?

Oh ! and you forgot tests!

![mind blowing](/assets/images/uploads/giphy.gif)

While making our own choices and testing we learnt a lot but nothing in
particular.


[1]: http://electron.atom.io/
[2]: http://phonegap.com/
[3]: http://nativescript.org/
