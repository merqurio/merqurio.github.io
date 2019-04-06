---

layout: post
title: Creating an static site in 2019.
tags:
- Javascript
- HTML
- Hugo
- IOMED

---


I’ve (side) worked as a full-stack developer since 2008. It was the easiest way
to give some use to the coding skills I acquired thanks to my uncle Pierre and
made me economically sustainable during my uni years.

Being Javascript the first language I self-taught (the first language I learned
was [Logo][logo]) it will always have a special place on my heart, but the
rapid evolution of the frontend tooling during the last 7-8 years made me
develop a love-hate relationship with it.

One of the features that I loved from JS was the ease to write a script and run
it on any browsers. It was a simple, effective and easy way to learn and share
with others. Then Node came out along with ES5 and the ecosystem started to
change. To run some JS it was not enough to import a script, you needed to
compile it.

This didn’t bother me much at the beginning, but I do remember perfectly the
day we stopped using bower and adopted npm to manage third-party libraries and
setup compiling pipelines. Something started to feel wrong. I didn’t realize at
the moment but it was the beginning of a huge complexity increase.

Filling the readme files with instructions on how to `npm install`, `npm run
dev`, `grunt watch` then `gulp`, `webpack`, etc… and having to educate
collaborators and content editors alike on the command line and nodejs install,
raised a lot of frustration on both sides. Then single page applications raised
with Angular, Amber, React … and made everything feel even messier.

The thing is that I’m still in love with static sites. In fact, this site is a
static Jekyll site, but the lack of i18n and l10n in Jekyll made it sometimes
painful.

#### Some fresh air

After a notoriously failed outsourcing of our companies corporate site, a
couple of weeks ago we agreed to rebuild the site ourselves. The previous site
was a static site generated with Jekyll, but this time I wanted something
better suited for the job. I also wanted to avoid taking care of a backend or
database, so I ended up checking the [Jamstack][jam] site somehow.


I discovered [Netlify][net] and [Hugo][hugo] there. Netlify is file-based git aware
front-end only CMS. No backend is needed! Amazing. Any modification becomes a
`git commit`, perfect for CI/CD integration. Any modification to the site opens
a merge request that if accepted, deploys directly to production. Hugo is
almost a rewrite of Jekyll using Golang templates. Being familiar with Golang
templates made it a pleasure to transition from Jekyll to Hugo.


#### Handling the multilingual problem.

I really liked Hugo's approach to localization and internationalization. It
differs content translation to your site localization from the beginning. I
created a whole Hugo theme for the site, so I took care of the i18n of the
theme, in the theme itself.


##### Configuring themes localization

When undertaking a multilingual project the first step is deciding the
languages you want to support. Hugo's language management reminded me to the
`.po` files. In this case, you can store all the string translation in the
theme itself using the translation identifier as the file name:

```sh
themes/iomed/i18n/
├── cat.yaml
├── de.yaml
├── en.yaml
├── es.yaml
├── eus.yaml
└── fr.yaml
```

Then it's as easy giving a unique id to the string translation and define the
default translation for that string in the `other` key. If the translation has
a singular form that differs from the plural form, you can add the `one` key to
the dictionary. Simple, fast, clean.

```yaml
cookieHeader:
  other: Preferencias sobre las Cookies

pages:
  one: Una página
  other: Varias páginas
```

To use the string, it's as simple as invoking the `i18n` function in the
template with the key to the translation string.

```html
{% raw %}
<form>
    <label>{{ i18n "cookieHeader" . }}</label>
    [...]
</form>
{% endraw %}
```

It will render:
```html
<form>
    <label>Preferencias sobre las Cookies</label>
    [...]
</form>
```

##### Configuring content localization

Configuring the supported content languages is as easy as specifying it in the
`config.yml`:

```yaml
languages:
  es:
    weight: 1
    languageName: Español
  en:
    weight: 2
    languageName: English
```

And creating a content file with the language key reference in the filename,
just before the file extension:

```sh
gabi@book[~/repos/iomed_site] (dev)▸ ls content/
total 16
-rw-r--r--   1 gabi  staff   1.2K Mar 21 12:40 _index.en.md
-rw-r--r--   1 gabi  staff   1.3K Apr  2 11:37 _index.md
[...]
```

#### The joy and speed of Hugo development

Thanks to this ease to support multilingual content with Hugo we were able to
ship the complete site under two weeks of side development. Definitely, the
familiarity with Golang templates helped a lot, making the whole experience
very joyful again, as in the old times.

Please go and check the site, we are still changing some parts of it, but we
are happy with the end result.


[https://iomed.health][io]

[io]: https://iomed.health
[hugo]: https://gohugo.io/
[net]:  https://www.netlifycms.org/
[logo]: https://en.wikipedia.org/wiki/Logo_(programming_language)
[jam]: https://jamstack.org/
