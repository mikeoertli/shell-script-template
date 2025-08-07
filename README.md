# Shell Script Template

<p align="center">
<img width="400" alt="Bash" src="images/bash-full.png"/>
</p>

This is the baseline Bash shell script template I use for new projects, from the simple to the complex.

A huge hat tip to the original foundation I used for this on [betterdev.blog](https://betterdev.blog/minimal-safe-bash-script-template/)
([raw source](https://gist.github.com/m-radzikowski/53e0b39e9a59a1518990e76c2bff8038)). Another blog resource I referenced and learned
from was on [betterprogramming.pub](https://betterprogramming.pub/my-minimal-safe-bash-script-template-300759114040).

This has been tested and used almost exclusively on macOS, but I don't _think_ there is anything specific to macOS built into the script,
or at least not to the detriment of any other platforms.

## How To Use

Copy the `shell-script-template.sh` file into your new script:

```sh
cp shell-script-template.sh my-new-script.sh
```

Customize the script for your solution.

> Hint: Search for "TODO", the areas that require focus are tagged with TODOs.

The highest priority changes are to modify the `usage` function to print out a summary about the script and update/remove the options
for your script, update the argument parsing that corresponds to the `usage` information, then implement the body of the script.

There are some "nice to have" changes like adding parameter validation, additional utility functions, etc.

## Misc. Info and Resources

### Parsing Parameters/Arguments

You will notice that `getopt` is not used, this is because of an [incompatibility with macOS](https://stackoverflow.com/a/11778003).

### Colorized Output

Colorized output uses 3 and 4-bit colors ([more info on Wikipedia](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)) and has
only really been tested on very dark backgrounds. Where multiple variants of a color exist, I typically used the bright variant.
There is also some great discussion on the topic [on StackExchange](https://unix.stackexchange.com/a/438357).

### ShellCheck LINTing

I highly recommend the [ShellCheck](https://github.com/koalaman/shellcheck) LINTing tool, it provides a lot of really useful feedback
regarding problematic or error-prone aspects of a shell script.

## Testing

Unit testing for shell scripts is a wide-ranging topic with no shortage of available libraries. I have only just begun this research,
but so far [this summary on Medium from wemake-services](https://medium.com/wemake-services/testing-bash-applications-85512e7fe2de)
seems to have a nice concise outline of pros/cons of some common libraries. This [dodie/testing-in-bash](https://github.com/dodie/testing-in-bash)
repo also contains a useful overview of feature support for popular libraries.

I am inclined to use [`bats-core`](https://github.com/bats-core/bats-core), but I suspect there are several good choices.

## Future Ideas

* Explore building in an example for [secure credential retrieval](https://scriptingosx.com/2021/04/get-password-from-keychain-in-shell-scripts/) (or create a second template script?).
