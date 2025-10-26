---
title: Are transformers all we need?
date: 2025-10-26 00:00:00 Z
layout: post
---

I vividly remember November 10th, 2017, the day I first read the ["Attention is
All You Need"][1] paper. I was in the Paris CDG airport. It struck me how similar
the architecture was to the autoencoders I had learned about just a few months
earlier at the DeepLearn 2017 in Bilbao. The attention mechanism (which I later
learned originated from [Dzmitry Bahdanau's][2] 2014 work) seemed like a remarkably
elegant solution. It captivated me, sparking my deep dive into AI and shaping my
career in applying these models to real-world problems, but I never imagined it
would become the phenomenon it is today.

This architecture is extraordinary, not just another neural network, but an
incredibly general one. Scaling laws in neural networks—where performance improves
predictably with more data and compute—are largely a property of transformers.
Before them, LSTMs and similar architectures didn't scale cleanly; they didn't
train well or exhibit predictable loss reduction. Transformers changed that:
they scale, train via backpropagation, and adapt to tasks seamlessly, from
language translation to image generation.

We stumbled upon something amazing in the algorithm space. Key innovations
include residual connections, layer normalization, the attention mechanism, and
the absence of saturating nonlinearities like tanh, which would kill gradient
flow. Google combined these elements, and suddenly, scaling laws emerged,
enabling reliable training.

This architecture isn't just powerful, it's foundational for the AI advancements
we're seeing today. In healthcare, for instance, transformers power models that
analyze vast clinical datasets, enabling better diagnostics and personalized
treatments. As we refine data and models, transformers might indeed be all we
need, or at least the cornerstone of what's next.

But where do we get the data to train these models? Internet data isn't the
ideal training set for transformers, it's more like a consequence of the need
for huge datasets, a distant cousin that surprisingly gets you far. What we
really want is the inner thought monologue of the human brain: the mental
trajectories during problem-solving. If we had billions of those, AGI would be
within reach. But we don't.

It's interesting that the actual LLMs can help to generate billions of
thought monologues and that we will see a future where synthetic data is more
important than ever. This bootstrapping approach could accelerate progress toward
more capable AI, especially in domains like medicine where real data is scarce
or sensitive.

![controlling an LLM](/assets/images/uploads/llm-control.jpeg)
Fig 1: Image from [Uber's blog post](https://www.uber.com/en-ES/blog/pplm/) on Controlling Text Generation


I'm observing a reality in which we're all trying to control this LLM
mammoth to get them where we want. Maybe we should focus more on the data, and
building/deploying smaller models that are only possible thanks to LLMs, but
that are not that heavy for production environments. Moving the heavy load only
to the development phase could make AI more accessible and efficient in fields
like healthcare, where real-time inference matters.

Given that Anthropic recently [proved][3] that a small number of samples can
poison LLMs of any size and there is a [lot of work][4] to try to make small
size models to reason and perform well, as always, the future lies in the
quality of the data. In my work at IOMED, ensuring data integrity is crucial for
reliable AI in medicine.

Time to rethink how you're making sure that your data is really high quality or
well fit for your end goal.



[1]: https://arxiv.org/abs/1706.03762#
[2]: https://arxiv.org/abs/1409.0473
[3]: https://www.anthropic.com/research/small-samples-poison
[4]: https://alexiajm.github.io/2025/09/29/tiny_recursive_models.html
