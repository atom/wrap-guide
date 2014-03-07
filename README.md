# Wrap Guide package

Displays a vertical line at the 80th character in the editor.

This packages uses the config value of `editor.preferredLineLength` when set.

You can change the color with the following CSS rule:

```css
.editor .wrap-guide {
  background-color: green;
}
```

You can use custom columns for different file types by adding something
similar to the following to your `~/.atom/config.cson` file:

```coffee
'wrap-guide':
  'columns':
    '\\.mm$': 120
    '\\.java$': 100
    '.*': 90
```

The keys are regexes to match against the current path and the values are
the column number fo render the guide at.

![](https://f.cloud.github.com/assets/671378/2241976/dbf6a8f6-9ced-11e3-8fef-d8a226301530.png)
