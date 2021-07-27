# EvoRescueFragmentation

This repository contains the scripts used to create simulations and figures used in the paper "Evolutionary rescue in one dimensional stepping stone models", written by myself and Stephan Peischl. It contains a simulation (main.py), a file to generate parameters sheets (parameters_generator.py) and an example of a parameters file (Parameters.txt). Furthermore, it contains the R scripts and the output files of the simulations used for the figures in the main text.

The simulation can be used either on its own (which will take a default input output) or with an input parameters file and output file with custom names: 
```
python3 main.py
python3 main.py fileOfParameters.txt outputName.txt
```

Keep in mind that these simulations where created in a time when my Python skills were those of a fledgling. If a line surprises you as too complicated, it's probably because I came up with a way to do it without ever knowing there was a faster or easier way.

For quick inquiries and questions about the code, feel free to open an issue here on github or to DM me on Twitter, @mattomasini; for more complicated questions concerning concepts discussed in the paper, please write to Dr. Stephan Peischl (you can find the address in the paper).

