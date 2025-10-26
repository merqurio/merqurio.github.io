---
title: Are transformers all we need?
date: 2025-10-26 00:00:00 Z
layout: post
---

I vividly remember November 10th, 2017, the day I first read the "Attention is
All You Need" paper. I was in the Paris CDG airport. It struck me how similar
the architecture was to the autoencoders I had learned about just a few months
earlier at the DeepLearn 2017 in Bilbao. The attention mechanism, which I later
learned originated from Dzmitry Bahdanau's 2014 work, seemed like a remarkably
elegant solution. It captivated me, but I never imagined it would become the
phenomenon it is today.

This architecture is extraordinary, not just another neural network, but an
incredibly general one. Scaling laws in neural networks are largely a property
of transformers. Before them, LSTMs and similar architectures didn't scale
cleanly; they didn't train well or exhibit predictable loss reduction.
Transformers changed that: they scale, train via backpropagation, and adapt to
tasks seamlessly.

We stumbled upon something amazing in the algorithm space. Key innovations
include residual connections, layer normalization, the attention mechanism, and
the absence of saturating nonlinearities like tanh, which would kill gradient
flow. Google combined these elements, and suddenly, scaling laws emerged,
enabling reliable training.

This architecture isn't just powerful, it's foundational for the AI advancements
we're seeing today. As we refine data and models, transformers might indeed be
all we need, or at least the cornerstone of what's next.

But where do we get the data to train these models? Internet data isn't the
ideal training set for transformers, it's more like a consequence of the need
for huge dataset, a distant cousin that surprisingly gets you far. What we
really want is the inner thought monologue of the human brain: the mental
trajectories during problem-solving. If we had billions of those, AGI would be
within reach. But we don't.
