# autobatch
A small [LÖVE](https://love2d.org/) (0.10.x) module which automatically uses
[SpriteBatches](https://love2d.org/wiki/SpriteBatch) when drawing the same image
multiple times in a row.


## Usage
The [autobatch.lua](autobatch.lua?raw=1) file should be dropped into an existing
project, and the following line put at the top of your `main.lua` file:

```lua
require "autobatch"
```

The module overrides `love.graphics` and should work automatically without any
additional changes to your code.


## License
This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.
