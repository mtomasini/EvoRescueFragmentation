"""
Created: 2018
Updated: May 21 2021
Commented: October 2020
Author: Matteo Tomasini
Paper: Fragmentation helps evolutionary rescue in highly connected habitats
doi: https://doi.org/10.1101/2020.10.29.360842
In this script, we generates a file of parameters to be used in "main.py". Just introduce the parameters you want
to simulate in the lists (e.g. list_of_generations, list_of_migration_rates) and the script generates the right format.
Python version: 3.X (last tested: 3.6)
"""

import numpy as np

header = [['TotalGenerations', 'Demes', 'TotalKappa', 'migration', 'isGlobal', 'mutation', 'mutantFrequency', 'growth', 's', 'r', 'z',
           'replicates', 'Rescue', 'Error']]
output = open('Parameters.txt', 'w')
np.savetxt(output, header, fmt='%s')
output.close()

replicates = 1000
probability_of_rescue = 0.0
confidence_interval = 0.0

# structure of the habitat #
list_of_demes = [4, 16]
# epoch = 50.
list_of_generations = [4800]
list_of_carrying_capacities = [20000]
list_of_migration_rates = np.logspace(-4, 0, 25)   # [0.00032, 0.02154, 0.68129]  #   np.logspace(-4, 0, 25)
list_of_isGlobal = [True, False]
list_of_mutation_rates = [1. / list_of_carrying_capacities[0]]
initial_frequencies = [0.0000]   # These are redefined later, in the loop.
list_of_growth_rates = [1.05, 1.5]  # Growth rates must be > 1

# selection coefficients
list_of_selection_for = [0.02]    # Selection in favor of mutants in deteriorated environment, > 0
list_of_selection_against = [0.5]  # Selection against mutants in non-deteriorated environment, > 0
list_of_stress = [0.5]  # Selection against wildtype in deteriorated environment , > 0

for total_number_of_generations in list_of_generations:
    for total_carrying_capacity in list_of_carrying_capacities:
        for demes in list_of_demes:
            for migration_rate in list_of_migration_rates:
                for mutation_rate in list_of_mutation_rates:
                    for globality in list_of_isGlobal:
                        for mutant_frequency in initial_frequencies:
                            for growth_rate in list_of_growth_rates:
                                for selection_against in list_of_selection_against:
                                    mutant_frequency = mutation_rate / selection_against
                                    for stress in list_of_stress:
                                        for selection_for in list_of_selection_for:
                                            parameters = [[total_number_of_generations, demes,
                                                           total_carrying_capacity, migration_rate, globality,
                                                           mutation_rate, mutant_frequency, growth_rate,
                                                           selection_against, stress, selection_for,
                                                           replicates, probability_of_rescue, confidence_interval]]
                                            output = open('Parameters.txt', 'a')
                                            np.savetxt(output, parameters, delimiter='\t', fmt='%.5f')
                                            output.close()
