---
title: Redrawing a brain with Bokeh
date: 2015-11-25 00:00:00 Z
layout: post
---

<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
After a [first attempt](http://merqur.io/2015/10/02/drawing-a-brain-with-bokeh/) of drawing a [connectome](https://en.wikipedia.org/wiki/Connectome) _(map of neural connections in the brain)_, I came up with a more ambitious idea for a visualization. **Draw one and each of the lines in the square matrix**. We are talking about an average of ±80.000 lines. [Bokeh](http://bokeh.pydata.org/en/latest/) seemed to be performant enough in the last visualization I made, with this one, we will see where the actual limits are.

### If not dots, then what ?
Arcs, [arcs](http://bokeh.pydata.org/en/latest/docs/reference/models/glyphs.html#bokeh.models.glyphs.Arc) is the answer to that question. If we know the **number of connections in a region** we can figure out the percent that each area **represents in the length of a circumference**; creating each area as an arc scaled with that length, the sum will be a complete circle.

An arc in Bokeh is a glyph and to be drawn needs: `'x', 'y', 'radius', 'start_angle', 'end_angle'` and `'direction'`. X and Y are the center of my circle (0,0) and the radius will be 1 to make things easier. The **missing values are `start_angle` and `end_angle`** ; with them we will be able to draw the arcs and the circumference.


#### Loading the info

To know the length that each area should have, we need first of all to know the number of connections that each area has.

{% highlight python %}
import numpy as np
connectome = np.load('connectome.npy')
weights_of_areas = (connectome.sum(axis=0) + connectome.sum(axis=1)) - connectome.diagonal()
{% endhighlight %}

Now that we know the number of connections per area, we can know the length that it would represent in a circunference. For that, I will use radians and **_radius = 1_** to make operations easier.

![](/assets/img/posts/QWwfy.gif)


{% highlight python %}
from math import pi
areas_in_radians = (weights_of_areas/weights_of_areas.sum()) * (2 * pi)
{% endhighlight %}

If this is this operation was correct, the sum should be near a 2π radians.

{% highlight python %}
from math import isclose
isclose(2*pi, areas_in_radians.sum())
{% endhighlight %}

    True

An arc of a circle is a "portion" of the circumference of the circle. The length of an arc is simply the length of its "portion" of the circumference. Now that we now the length of each area in a circumference **we need to know the start and end angles** of the arc in order to be able to draw them. The radian measure, `ø`, of a central angle of a circle is defined as the ratio of the length of the arc the angle subtends, `s`, divided by the radius of the circle, `r`.

$$\emptyset = \frac{s}{r} = \frac{lenght\ of\ arc}{length\ of\ radius} = \frac{s}{1}$$

So in this case `ø = s` makes everything much easier. Our points must start on zero, so I add a zero in the begining of the array.


{% highlight python %}
points = np.zeros((areas_in_radians.shape[0]+1)) # We add a zero in the begging for the cumsum
points[1:] = areas_in_radians
points = points.cumsum()
{% endhighlight %}


{% highlight python %}
start_angle = points[:-1]
end_angle = points[1:]
{% endhighlight %}

Let's add some color using the function we already created for the previous connectome.


{% highlight python %}
from colorsys import hsv_to_rgb
def gen_color(h):
    golden_ratio = (1 + 5 ** 0.5) / 2
    h += golden_ratio
    h %= 1
    return '#{:02X}{:02X}{:02X}'.format(*tuple(int(a*100) for a in hsv_to_rgb(h, 0.55, 2.3)))
{% endhighlight %}


{% highlight python %}
colors = np.array([gen_color(area/areas_in_radians.shape[0]) for area in range(areas_in_radians.shape[0])])
{% endhighlight %}

#### Creating the arcs

{% highlight python %}
from bokeh.plotting import output_notebook, show, figure, ColumnDataSource
from bokeh.models import Range1d
{% endhighlight %}

The easiest way is to create a ColumnDataSource instance with the data we need to create the arcs in order to reuse this same instance later on.

{% highlight python %}
arcs = ColumnDataSource(
    data=dict(
        x=np.zeros(connectome.shape[0]),
        y=np.zeros(connectome.shape[0]),
        start=start_angle,
        end=end_angle,
        colors=colors)
    )
{% endhighlight %}

We configure the plot

{% highlight python %}
p = figure(title="Connectomme",
           outline_line_color="white",
           toolbar_location="below")

# grid configurations
p.x_range = Range1d(-1.1, 1.1)
p.y_range = Range1d(-1.1, 1.1)
p.xaxis.visible = False
p.yaxis.visible = False
p.xgrid.grid_line_color = None
p.ygrid.grid_line_color = None

p.arc(x='x', y='y', start_angle='start', end_angle='end',
      radius=1, line_color='colors', source=arcs, line_width=10)
{% endhighlight %}

And print it !

{% highlight python %}
output_notebook(hide_banner=True)
show(p)
{% endhighlight %}

<div class="embed-container bokeh">
  <iframe width="420" height="315" frameborder="0" src="/notebooks/bokeh_brains_v2/only_arcs.html">
  </iframe>
</div>


### I got those arcs, now what ?
    bokeh.crazy_scientific_mode = True

Now let's get into the real stuff. **Drawing so many lines is not an easy task**, so I did it using [OOP](https://en.wikipedia.org/wiki/Object-oriented_programming) to make it more understandable. I'm sure there is someone reading this and thinking, *"meh, I can do that without declaring a class"* for those; please, do it and share your approach.

We can create each area as an arc with it's start and end point and the number of connections there should be in that area.

{% highlight python %}
from math import cos, sin
class Area():
    """
    It represents a brain area. It will create a list of available points throught the arc representing that area and then we will
    use those points as start and end for the beziers.
    """
    def __init__(self, n_conn, start_point, end_point):
        self.n_conn = n_conn # Number of connections in that area
        self.start_point = start_point # The start point of the arc representing the area
        self.end_point = end_point
        free_points_angles = np.linspace(start_point, end_point, n_conn) # Equally spaced points between start point and end point
        self.free_points = [[cos(angle), sin(angle)] for angle in free_points_angles] # A list of available X,Y to consume
{% endhighlight %}

Now we generate each of the areas in the connectome as an object and store them in a list.

{% highlight python %}
all_areas = []
for i in range(start_angle.shape[0]):
    all_areas.append(Area(weights_of_areas[i], start_angle[i], end_angle[i]))
{% endhighlight %}

Each of those areas we just created has all the points(x,y) that the connections will start from or go to. Those points are in the same space than the arcs we defined earlier. That will create the illusion that the lines are created from the arc, as they will share the same color that the arc they were started from.

Now we have to create each of those lines. The easiest thing is just to loop through all the areas and create each connection.

{% highlight python %}
all_connections = []
for j, region1 in enumerate(connectome):
    # Get the connections origin region
    region_a = all_areas[j]
    color = colors[j]
    weight = weights_of_areas[j]

    for k, n_connections_region2 in enumerate(region1):
        # Get the connection destination region
        region_b = all_areas[k]
        for i in range(int(n_connections_region2)):
            p1 = region_a.free_points.pop()
            p2 = region_b.free_points.pop()
            # Get both regions free points and create a connection with the data
            all_connections.append(p1 + p2 + [color, weight])
{% endhighlight %}


{% highlight python %}
len(all_connections)
{% endhighlight %}


    4740

We have `4740` connections in total that we will draw in the plot. Let's store them in a DataFrame to easily create a ColumnDataSource later on.


{% highlight python %}
import pandas as pd
connections_df = pd.DataFrame(all_connections, dtype=str)
connections_df.columns = ["start_x","start_y","end_x","end_y","colors", "weight"]
{% endhighlight %}

I store the values in the DataFrame as strings to store as many precission as possible. I found that storing them as floats, made me lose lot of precission and bokeh is taking the string values without problems.

Now we create the curves and add them to the DataFrame


{% highlight python %}
connections_df["cx0"] = connections_df.start_x.astype("float64")/2
connections_df["cy0"] = connections_df.start_y.astype("float64")/2
connections_df["cx1"] = connections_df.end_x.astype("float64")/2
connections_df["cy1"] = connections_df.end_y.astype("float64")/2
{% endhighlight %}

We standarize the weights and give them a value that will make them visible. With this, the most important areas will be much more opaque than those with less number of connections.


{% highlight python %}
connections_df.weight = (connections_df.weight.astype("float64")/connections_df.weight.astype("float64").sum()) * 3000
{% endhighlight %}


{% highlight python %}
connections_df.head()
{% endhighlight %}




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>start_x</th>
      <th>start_y</th>
      <th>end_x</th>
      <th>end_y</th>
      <th>colors</th>
      <th>weight</th>
      <th>cx0</th>
      <th>cy0</th>
      <th>cx1</th>
      <th>cy1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0.988303</td>
      <td>0.152505</td>
      <td>0.96114</td>
      <td>0.276062</td>
      <td>#6779e5</td>
      <td>0.093366</td>
      <td>0.494151</td>
      <td>0.076253</td>
      <td>0.480570</td>
      <td>0.138031</td>
    </tr>
    <tr>
      <th>1</th>
      <td>0.988404</td>
      <td>0.151848</td>
      <td>0.961324</td>
      <td>0.275422</td>
      <td>#6779e5</td>
      <td>0.093366</td>
      <td>0.494202</td>
      <td>0.075924</td>
      <td>0.480662</td>
      <td>0.137711</td>
    </tr>
    <tr>
      <th>2</th>
      <td>0.988505</td>
      <td>0.15119</td>
      <td>0.918333</td>
      <td>0.395809</td>
      <td>#6779e5</td>
      <td>0.093366</td>
      <td>0.494252</td>
      <td>0.075595</td>
      <td>0.459166</td>
      <td>0.197905</td>
    </tr>
    <tr>
      <th>3</th>
      <td>0.988605</td>
      <td>0.150532</td>
      <td>-0.644647</td>
      <td>0.76448</td>
      <td>#6779e5</td>
      <td>0.093366</td>
      <td>0.494303</td>
      <td>0.075266</td>
      <td>-0.322324</td>
      <td>0.382240</td>
    </tr>
    <tr>
      <th>4</th>
      <td>0.988705</td>
      <td>0.149873</td>
      <td>-0.64414</td>
      <td>0.764907</td>
      <td>#6779e5</td>
      <td>0.093366</td>
      <td>0.494353</td>
      <td>0.074937</td>
      <td>-0.322070</td>
      <td>0.382454</td>
    </tr>
  </tbody>
</table>
</div>



Once again, using ColumnDataSource I store all the data from the pandas DataFrame in a bokeh compatible object


{% highlight python %}
# Bezier lines
beziers = ColumnDataSource(connections_df)
{% endhighlight %}

Aaaaaaand let's plot it


{% highlight python %}
p2 = figure(title="Connectomme",
           outline_line_color="white",
           toolbar_location="below")

# grid configurations
p2.x_range = Range1d(-1.1, 1.1)
p2.y_range = Range1d(-1.1, 1.1)
p2.xaxis.visible = False
p2.yaxis.visible = False
p2.xgrid.grid_line_color = None
p2.ygrid.grid_line_color = None
{% endhighlight %}

Add the glyphs to the plot...


{% highlight python %}
p2.bezier('start_x', 'start_y', 'end_x', 'end_y', 'cx0', 'cy0', 'cx1', 'cy1',
             source=beziers,
             line_alpha='weight',
             line_color='colors')
p2.arc(x='x', y='y', start_angle='start', end_angle='end',
      radius=1, line_color='colors', source=arcs, line_width=10)
{% endhighlight %}




    <bokeh.models.renderers.GlyphRenderer at 0x111a7da58>



And Voilá !


{% highlight python %}
show(p2)
{% endhighlight %}

<div class="embed-container bokeh">
  <iframe width="420" height="315" frameborder="0" src="/notebooks/bokeh_brains_v2/full_connectome.html">
  </iframe>
</div>


Sadly, taking all the connections would make your browser process tooooooo much info when generating the visualization. What you see here is just a rendering of the `connectome[:40][:40]` You can try the full visualization with the [jupyter notebook](/notebooks/bokeh_brains_v2/BokehBrain.zip) but use at your own risk ;)


### Cool, but some things are still missing...
This is a work in progress, working on this visualization I found several limitations in Bokeh.

- Add WebGL support for arcs and beziers
- Add HoverTool to arcs to display information on the areas
- Add TapTool to arcs to be able to display only the connections originated from one area
- Create a bokeh interface for Chord graphs

I hope that with my time and the help of the community we can get these working. That would give you the ability Chord graphs just by passing an square matrix.
My hope is that in the next several months we can see this integrated inside Bokeh.

Thanks for passing by, you can download all the code [HERE](/notebooks/bokeh_brains_v2/BokehBrain.zip)!
