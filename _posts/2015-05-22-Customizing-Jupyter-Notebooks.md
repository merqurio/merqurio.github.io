---
title: Customising Jupyter notebooks
date: 2015-05-22 00:00:00 Z
layout: post
---

### Syntax Highlighting
Lately, I've been working a lot on Python using the [Jupyter Notebooks](http://jupyter.org). I don't like some of the styling in the notebooks, but that isn't a problem at all, what it was annoying for me was the lack of syntax highlighting, therefor I decided to create a plugin on my own so I can change the colouring with a click.

The result, a list to select between the [Base16](chriskempson.github.io/base16/) themes:

![Screenshot of my Jupyter Notebook](http://lh3.googleusercontent.com/7Oc3PuBnm79ES9bK65hX4tfNvYwpW5oSU_G1FwKGe6xDlsWUzirnedFBtXgdUjkKh0tePzvG6W3sHfmucZWZiKScqQ=s1600)
----

This way anyone can have Jupyter themes and select between a bunch of different themes, the best way to check the themes is installing plugin or at [Base16](http://chriskempson.github.io/base16/). Note that the themes are not 100% exact and that's because the syntax highlighting offered by [CodeMirror](https://codemirror.net/) (The JS that does the colouring) is limited.

It's really easy to install a get it working just open your terminal *(#NIX systems)* and type: 

{% highlight sh %}
$ git clone https://github.com/merqurio/jupyter_themes.git --depth 1
$ cd jupyter_themes
$ cp -r **  $(ipython locate)/nbextensions/
{% endhighlight %}

Then you need to initialised the plugin every time you open the Jupyter Notebook. This part might vary depending on your installation, but if you just did the normal Jupyter installation:

{% highlight sh %}
$ nano $(ipython locate)/profile_default/static/custom/custom.js
{% endhighlight %}

and add:
{% highlight javascript %}
$([IPython.events]).on("app_initialized.NotebookApp", function () {
    IPython.load_extensions('theme_selector');
});
{% endhighlight %}


