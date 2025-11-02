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

This discovery marked the beginning of my journey into this area of AI, a
journey that started with the sheer magic of transformers, evolved through the
harsh realities of data limitations, and now points toward a future where
quality data and specialized models redefine what's possible.

The magic of transformers lies in their extraordinary generality. They're not
just another neural network; they're an incredibly adaptable one. Scaling laws
in neural networks, where performance improves predictably with more data and
compute, represent the best property of transformers. Before them, LSTMs and
similar architectures didn't scale cleanly; they didn't train well or exhibit
predictable loss reduction. Transformers changed that: they scale, train via
backpropagation, and adapt to tasks seamlessly, from language translation to
image generation.

We stumbled upon something amazing in the algorithm space. Key innovations
include residual connections, layer normalization, the attention mechanism, and
the absence of saturating nonlinearities like tanh, which would kill gradient
flow. The authors combined these elements, and suddenly, scaling laws emerged,
enabling reliable training. This architecture isn't just powerful, it's
foundational for the AI advancements we're seeing today. As we refine data and
models, transformers might indeed look like all we need, or at least the
cornerstone of what's next.

But then comes the big challenge: where does the data for training these models
actually come from? Most transformers are trained on huge volumes of internet
data. That’s not ideal—this kind of data is messy, noisy, and only loosely
matched to the skills we actually want to teach these models. Still, it’s what
we have, and for now, it works well enough.

What we really wish we had, though, is something much more valuable:
thought monologue of the human brain: the mental trajectories during
problem-solving. It's not just the answer, but the process of arriving at the
answer, the dead ends, the connections, the reasoning. If we had billions of
those, AGI would be within reach. But we don't.

This gap has led to a fascinating bootstrapping approach. LLMs can generate
billions of synthetic thought monologues, and we're entering a future where
synthetic data becomes more important than ever. Techniques like model
distillation where a large model "teaches" a smaller one—allow us to create
efficient, specialized models that capture the essence of their bigger
counterparts. This could accelerate progress toward more capable AI, especially
in domains like medicine where real data is scarce or sensitive.

![controlling an LLM](/assets/images/uploads/llm-control.jpeg)
Fig 1: Image from [Uber's blog post](https://www.uber.com/en-ES/blog/pplm/) on Controlling Text Generation

Yet, as illustrated in the image above, we're currently focused on building
complex harnesses to steer these massive models. But what if the problem isn't
the steering, but the engine's fuel? Maybe we should focus more on the data,
and building/deploying smaller models that are only possible thanks to LLMs,
but that are not that heavy for production environments. Moving the heavy load
only to the development phase could make AI more accessible and efficient in
fields like healthcare, where scale and data governance matters.

Given that Anthropic recently [proved][3] that a small number of samples can
poison LLMs of any size and there is a [lot of work][4] to try to make small
size models to reason and perform well, as always, the future lies in the
quality of the data.

Rethink how you ensure your data is high quality and well-suited for your end goal.

Transformers gave us the engine for a new kind of intelligence. But an engine,
no matter how powerful, is useless without the right fuel. The next great leap
in AI won't come from building bigger models, but from the painstaking, crucial
work of curating and creating data that truly reflects the reasoning we want to
emulate.


[1]: https://arxiv.org/abs/1706.03762#
[2]: https://arxiv.org/abs/1409.0473
[3]: https://www.anthropic.com/research/small-samples-poison
[4]: https://alexiajm.github.io/2025/09/29/tiny_recursive_models.html
[5]: https://arxiv.org/abs/2001.08361
