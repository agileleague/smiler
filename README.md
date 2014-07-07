# Smiler

Smiler is a just-for-fun project designed to show what can be
accomplished with data visualization using [D3.js](http://d3js.org) and
[SVGs](http://www.w3.org/TR/SVG/).

## Architecture

Smiler is written in [Ember.js](http://emberjs.com) using
[CoffeeScript](http://coffeescript.org). The persistence layer is
[Firebase](http://firebase.com).

## Setup

Smiler is very simple, architecture-wise. To get it running, just:

1. Create a [Firebase](http://firebase.com) account.
1. Copy your Firebase URL namespace into the dev environment in
   config/environment.js
1. Fire it up!

## Organization

I'm afraid that I'm pretty new to Ember and my organization shows that.
I put a lot of the chart calculation and computation in controllers, and
I'm guessing it probably belongs in views. Oh well. If you are really
excited to refactor it, I'll definitely accept pull requests.

# About

Smiler was written primarily by Micah Wedemeyer and Drew Nolte of [The
Agile League](http://agileleague.com)
