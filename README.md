# arun

## For Linux User
`binfmt_misc` is better.

## note
The `A` executable requires a `Acnf.cnf` in its parent directory or cwd[^1] as a configure file[^2].   
See `Acnf.cnf`'s comment to learn its format.  
## desc
After configuring(optional),  
you can run `A` using one file or more as arguments,
it'll run them respectively, invoking configured compiler or interpreter.  
## help
For cli help, see src/clihelp.txt

[^1]: the current working directory
[^2]: prefer the former

