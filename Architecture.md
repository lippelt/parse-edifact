# Introduction #

Using [XSLT](http://en.wikipedia.org/wiki/XSLT) to transform an [XML/EDIFACT](http://en.wikipedia.org/wiki/XML/EDIFACT) instance to an [EDIFACT](http://en.wikipedia.org/wiki/EDIFACT) instance is quite natural, since an XSLT script can produce plain text output :-) On the other hand, the source document **must always be a well-formed XML instance**, which means that XSLT does not look like the ideal tool to transform an EDIFACT instance to an XML/EDIFACT instance :-(

But, when you have tasted the power of XSLT to transform XML/EDIFACT to EDIFACT, you cannot resign yourself not to use it for the other way!

And, finally, the trick is quite easy. You just need to **pre-parse** the **syntax** of the incoming EDIFACT instance using a super-simple grammar. Such a pre-parser is **very** simple to write in your preferred classic programming (scripting) language - you should end up with less than 100 lines of code - and give you a valid source document for an XSLT that will do the real work of transforming EDIFACT into XML/EDIFACT ;-)

# Pre-Parsing of the EDIFACT instance #

## My super-simple grammar ##

The root tag is **`<F>`**.

Every segment creates a **`<S>`** element, which are the only children of **`<F>`**. Each **`<S>`** element has a single **`<N>`** element as its first child. It contains the 3-letter code of the segment, e.g. UNH, BGM, DTM, etc.

Then, any _Data Element Separator_ creates a **`<U>`** element and **`<V>`** element, as child of the **`<U>`** element. The data that is just after the _Data Element Separator_ always go into the first **`<V>`** element.

Finally, after this data, you either got (1) a _Component Data Element Separator_ that creates a new following-sibling **`<V>`** element, (2) a new _Data Element Separator_ that creates a new **`<U>`** element, with its own **`<V>`** child element, or you reach the end of segment.

_**Done ;-)**_ But, it's always a good idea to give some **examples**...

### Example 1 ###

`BGM+220+123350+9'`
```
<S n="3">
  <N>BGM</N>
  <U>
    <V>220</V>
  </U>
  <U>
    <V>123350</V>
  </U>
  <U>
    <V>9</V>
  </U>
</S>
```

Remark. I have added a sequential counter to the **`<S>`** element, within the **`n`** attribute, for the optimization of the XSLT parser. You will see its usage later ;-)

### Example 2 ###

`DTM+4:20011107:102'`
```
<S n="4">
  <N>DTM</N>
  <U>
    <V>4</V>
    <V>20011107</V>
    <V>102</V>
  </U>
</S>
```

### Example 3 ###

`LIN+1++STU62001LW-K:BP'`
```
<S n="11">
  <N>LIN</N>
  <U>
    <V>1</V>
  </U>
  <U>
    <V/>
  </U>
  <U>
    <V>STU62001LW-K</V>
    <V>BP</V>
  </U>
</S>
```

### Example 4 ###

`IMD++3+:::SEAGATE VIPER EXT LVD 200G ULTRIUM'`
```
<S n="12">
  <N>IMD</N>
  <U>
    <V/>
  </U>
  <U>
    <V>3</V>
  </U>
  <U>
    <V/>
    <V/>
    <V/>
    <V>SEAGATE VIPER EXT LVD 200G ULTRIUM</V>
  </U>
</S>
```

## My Pre-Parsing Algorithm ##

1. Parse the UNA segment, or **set** the following parameters with their respective default values:

| _Segment Terminator_               | Chr(39) | ' |
|:-----------------------------------|:--------|:--|
| _Data Element Separator_           | Chr(43) | + |
| _Component Data Element Separator_ | Chr(58) | : |
| _Release Character_                | Chr(63) | ? |

2. **Set** the _Previous Delimiter_ as the _Segment Terminator_

3. **Loop**: read the next character into the _Current Character_ until the end of the EDIFACT instance:

3.1. **If** the _Current Character_ is the _Release Character_ **then** the _Value_ is concatenate with the next character.

3.2. **If** the _Current Character_ is the _Segment Terminator_ **then**

3.2.1. **If** the _Previous Delimiter_ is the _Data Element Separator_ **then**

3.2.1.1. Creates a **`<U>`** element and **`<V>`** element, as child of the **`<U>`** element, and

3.2.1.2. Set the text of **`<V>`** as the _Value_.

_To be continued..._