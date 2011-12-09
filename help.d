/*
Optimizer, a command line function minimization software.
Copyright (C) 2011  Pavel Sountsov

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

module help;

const char[] Help = 
`Optimizer, a command line function minimization software.
Copyright (C) 2011 Pavel Sountsov.

Usage: optimizer [OPTION]... [ALGORITHM_OPTION]... 
                 [--] COMMAND [COMMAND_OPTIONS]...
Example: optimizer -l=-1:1 -l=-1:1 -a de -v -- ./test --test_arg

COMMAND is expected to take a list of numerical parameters as its arguments 
(number of arguments equals to the number of limits specified) and output to 
stdout a number. Optimizer will try to vary the parameters such that this output
 is minimized.

COMMAND is allowed to output multiple lines of output: all but the last one will
be ignored. If you need to pass options to the COMMAND, use the '--' command
before the COMMAND. For example, the example usage above would call ./test like
so:

./test --test_arg -3.1e-1 5.0e-1

General options:
  -a,  --algorithm=ALGO           what algorithm to use for optimization. 
                                  Default: de
                                  
                                  Supported algorithms:
                                  
                                  de:    use Differential Evolution to pick 
                                         parameters
                                  grid:  pick parameters from a regularly spaced
                                         grid
  -h,  --help                     print this help text
  -j,  --jobs=NUMBER              number of jobs to use when evaluating COMMAND.
                                  Default: 1
  -l,  --limits=NUMBER:NUMBER...  set the limits for a parameter. Use multiple 
                                  invocations of this option to specify multiple
                                  limits, or specify multiple limits after a
                                  single invocation. NUMBER can be written in
                                  scientific notation.
  -v,  --verbose                  display extra progress information

Differential Evolution algorithm options:
       --de_strategy=NUMBER       what crossover strategy to use. Default: 0
       
                                  Supported strategies:
                                  
                                  0: DE/rand/1/bin
                                  1: DE/local-to-best/1/bin
       --de_maxgen=NUMBER         maximum number of generations to run.
                                  Default: 100
       --de_popsize=NUMBER        population size to use. By default it uses 10 
                                  times the dimensionality of the problem or 40,
                                  whichever is smaller. Population size will be 
                                  adjusted to 5 if it is less than 5.
       --de_factor=NUMBER         weighting factor. Must be betweeen 0 and 1. 
                                  Default: 0.8
       --de_cross=NUMBER          crossover probability. Must be between 0 and 
                                  1. Default: 0.9

Grid algorithm options:
       --grid_size=NUMBER...      specify the number of points to try for a 
                                  given dimension. The first number is used for 
                                  the first dimension, the second for the second
                                  etc. The dimensions for which the grid size is
                                  not specified default to a grid size of 2.
`;
