+++
title = "Design to Embrace Change"
slug = "design-to-embrace-change"
description = """\
A short discussion on Ruby design with object oriented programming."""
date = "2013-10-26"
tags = [ "ruby", "oop" ]
categories = [ "language", "design" ]
+++

So, I've been reading *[Practical Object-Oriented Design in Ruby][book]*
while also watching the VT football game today, something I am beginning to 
regret. During my freshman and sophomore years at Virginia Tech, I was 
introduced to quite a few concepts regarding [Object Oriented Programming][oop]. 
Mostly, these related to simplistic encapsulation of data - writing setters 
and getters for any and all variables - as well as using inheritance mixed 
with interfaces.

In *Practical Object-Oriented Design in Ruby*, the author has a chapter
dedicated to writing code that embraces change. While I assumed I "knew the
majority of these concepts," I swiftly learned that - once again - my ego had
blinded me from exploring many of the fascinating methodologies developed by
people much more clever than myself.

The author focuses on behavior over data. When methods are defined, they
should provide a behavior versus strict data manipulation. In addition, the
author also claims that classes should hold a single responsibility to reduce
complexity and ensure easy readability.

### 1. Encapsulation via Method Wrappers ###

The book begins by discussing abstraction in the form of encapsulation of data
in Ruby using shorthands like *attr_reader* to wrap field access. I was
already familiar with this one from my Extreme Blue internship with IBM this
past summer, where I had to quickly pick up and learn Ruby (1.9.3) to develop
our prototype. Below you can see an example of a poor design choice and a
better alternative - although not perfect, as you will see later.

#### 1.a Poor Design Choice ####

```ruby
class Rectangle
    def initialize(width, length)
        @width = width
        @length = length
    end

    def area
        @width * @length    # <-- poor design
    end
end
```

#### 1.b Better Design Choice ####

```ruby
class Rectangle
    attr_reader :width, :length
    def initialize(width, length)
        @width = width
        @length = length
    end

    def area
        width * length      # <-- better design
    end
end
```

#### Why is this better? ####

The shorthand *attr_reader* simply wraps the references to instance variables
in getter methods with the same name. E.g.

```ruby
def width
    @width
end

def length
    @length
end
```

You might ask why bother doing this? Well, for one, it saves you the headache
in writing wrapper methods for getters and setters that merely reference
variables without providing any alterations. However, in the future, you might
decide to change the functionality of width or height. Not likely - this is
an overly-simplistic example - but it could happen.

### 2. Leaky Abstractions ###

Enter the next section of the chapter, focusing on [leaky abstractions][la]. 
This was something that I believe I had touched on, but not worked with often.
The reason being that I was taught (and learned from experiences at IBM) to not
perform logical operations within class initialization. However, I am getting
ahead of myself, let me first provide an example of a leaky abstraction.

#### 2.a Leaky Abstraction ####

```ruby
class ObscuringReferences
    attr_reader :data
    def initialize(data)
        @data = data
    end

    def introduce_self
        "Hi, my name is #{data[0]} and I am #{data[1]}."
    end
end
```

The above poses a maintainability issue. The code is written where the 
*introduce_self* method is aware of the contents and order of the array *data*,
which is not something any sane programmer should want. Why? Suppose, in the
future, that the data array needs to be expanded such that it contains an
age, name, and description in that order. The *introduce_self* method would 
then need to be altered to match the data structure change.

#### 2.b Fixed Abstraction ####

```ruby
class RevealingReferences
    attr_reader :person
    def initialize(data)
        @person = personalize(data)
    end

    def introduce_self
        "Hi, my name is #{person.name} and I am #{person.description}"
    end

    # ...

    Person = Struct.new(:name, :description)
    def personalize(data)
        Person.new(data[0], data[1])
    end
end
```

Now we have something neat! The author brings up *[Struct][struct]*, a way to 
bundle fields together. Using it combined with a method dedicated to 
building the *Struct*, the code can now be written where all methods using the
data can be unaware of how it is provided. They just know what data they need
to use.

This is an interesting concept to me. I still believe that logic that performs
actions should absolutely *not* be found in the constructor of a class;
however, seeing this example of organizing input such that the class can
recognize and appropriately handle it is so simple yet powerful. I'm curious
if this falls under the normal "avoid at all cost" for those that advocate
removing logic from constructors, or if this is frequently performed.

### 3. Reuse Code ###

Okay, so, this one is incredibly obvious and has been drilled into the head of
every student attending a university in the last decade. Simply put, if there
is a segment of code that is used in multiple places, you should move it into
its own function/method. With *C*, you might inline the code or write a macro
for it if the code was small enough. In *Ruby*, you just move the code to a
new method.

However, the author takes this a step further by indicating that not only
should a class have a single responsibility but also each method should also
only perform a single task.

#### 3.a Too Much Functionality ####

```ruby
class RectangularPrism
    attr_reader :width, :length, :height
    def initialize(width, length, height)
        @width = width
        @length = length
        @height = height
    end

    def volume
        width * length * height
    end
end
```

I am fairly bad with examples - and I wanted to avoid using the book's
examples - so bare with the above. In this case, the *volume* method is
calculating the volume of a rectangular prism. The forumla can be given as
*width x length x height*. However, it can also be seen as *area x height*.
In other words, the volume method is performing a calculation of the area
and the volume, which is too much functionality.

#### 3.b Separated Functionality ####

```ruby
class RectangularPrism
    attr_reader :width, :length, :height
    def initialize(width, length, height)
        @width = width
        @length = length
        @height = height
    end

    def volume
        area * height
    end

    def area
        width * length
    end
end
```


Now we have separated the calculation of the area to its own method rather
than having this handled in the same method as the volume. The author states
that this provides the advantage of exposing additional functionality. Even
with the better example provided in his text, I'd still argue that this might
not be a great feature; however, I am fairly naive with dynamic languages like
*Ruby* - I prefer statically-typed languages (C, Java).

#### 3.c Avoid Comments ####

What I did find interesting was an additional comment from the author in his
list of benefits for this refactoring: avoid the need for comments. When I
read this, a flag immediately went up. Avoid comments? But you normally want
to properly document your code! Thinking back, I reference Linus Torvalds'
thoughts on [coding style][lcs], where he describes commenting. Torvalds says
that you should avoid over-commenting. My thoughts usually gravitate towards
the naive "restate how your code is working" versus explaining *what* your
code does.

Torvalds says to put comments in front of your functions (methods in our case)
to explain *what* they do versus having to explain the internals. This ties in
with his explanation of the length and complexity of functions. I'd recommend
giving his coding style document a once-over. I'd also like to point out a
similar document from [KOS][kos], the Dreamcast development framework, where
the original developer provides his own comments on [coding style][dcs].

So, I think both the author and Torvalds share a similar point of view in
terms of over-commenting. Looking back, I find myself extra guilty of
providing a plethura of comments within my functions/methods, many of which
were written cleanly enough where no additional explanation was needed.

[book]: http://www.amazon.com/Practical-Object-Oriented-Design-Ruby-Addison-Wesley-ebook/dp/B0096BYG7C
[oop]: http://en.wikipedia.org/wiki/Object-oriented_programming
[la]: http://en.wikipedia.org/wiki/Leaky_abstraction
[struct]: http://www.ruby-doc.org/core-2.0.0/Struct.html
[lcs]: https://www.kernel.org/doc/Documentation/CodingStyle
[kos]: http://gamedev.allusion.net/softprj/kos/
[dcs]: /docs/dreamcast_coding_style.txt

