"""
Created: 2018
Updated: 22 April 2021
Commented: october 2020
Author: Matteo Tomasini
Paper: Fragmentation helps evolutionary rescue in highly connected habitats
doi: https://doi.org/10.1101/2020.10.29.360842
In this script, we simulate evolutionary rescue in a habitat with multiple demes.
To work, the script needs a file called "Parameters.txt" that contains the parameters (see example in the folder).
Modify the variables in the beginning of the script to change the parameters of the simulation.
Python version: 3.X (last tested: 3.6)
"""

import sys
import numpy as np
import math
import time

BURNING_PHASE = 500                       	# Sets length of burn-in phase
BURNING_OFF = 500                       	# Number of generations simulated after deterioration is complete
STANDING_GENETIC_VARIATION = False       	# If True, simulation starts with SGV using f = u/s (no need for burn-in but imprecise)
IS_BEVERTON_HOLT = False                	# If True, uses Beverton-Holt dynamics in undeteriorated deme
DENSITY_REGULATION = True               	# If True, regulates density to carrying capacity at every generation
THRESHOLD = 0.5                         	# Percentage of carrying capacity necessary to declare rescue
IS_RANDOM = False                       	# If True, demes deteriorate at random (but still every theta generations)

# Define parameters file according to input from command line
if len(sys.argv) == 1:
    parameters_file = "./Parameters.txt"
    output_file = "./simulation_output.txt"
elif len(sys.argv) == 2:
    parameters_file = sys.argv[1]
    output_file = "./simulation_output.txt"
elif len(sys.argv) == 3:
    parameters_file = sys.argv[1]
    output_file = sys.argv[2]
else:
    raise NameError("Too many arguments in command line!")


def zero_maker(length):
    """
    Custom function to generate a vector of zeros (for readability).
    """
    list_of_zeros = [0] * length
    return list_of_zeros


def positive(number):
    """
    If the variable number is negative, it sets it to zero, if it's positive it's left untouched.
    """
    if number < 0:
        return 0
    else:
        return number


def deteriorate(what_time_is_it, is_random):
    """
    Deterioration states for each deme are set in a list. This function changes the list when t reaches different epochs.
    """
    # first check if all demes are deteriorated, do something only if not all are True.
    if sum(deme_deterioration_state) != len(deme_deterioration_state):
        for it in iteration_list:
            if what_time_is_it == (BURNING_PHASE + it * epoch + 1):
                if not is_random:
                    deme_deterioration_state[it] = True
                else:
                    deme_to_deteriorate = np.random.choice(iteration_list)      # pick a deme to deteriorate at random
                    while deme_deterioration_state[deme_to_deteriorate]:        # if the deme is already deteriorated (hence True)...
                        deme_to_deteriorate = np.random.choice(iteration_list)  # ...continue picking a deme until deme is non-det.
                    deme_deterioration_state[deme_to_deteriorate] = True
    else:
        pass


def expected_offspring(is_deteriorated, deme_population, deme_capacity, is_mutant):
    """
    Sets the expected number of offspring of a population.
    """
    if is_deteriorated and is_mutant:
        fitness = 1. + selection_for
    elif is_deteriorated and not is_mutant:
        fitness = 1. - stress
    elif not is_deteriorated and is_mutant:
        fitness = 1. - selection_against
    else:
        fitness = 1.

    if not IS_BEVERTON_HOLT:
        average_offspring = fitness
    else:
        if not is_deteriorated:
            average_offspring = growth_rate * fitness / (1 + (growth_rate - 1) * deme_population / deme_capacity)
        else:
            average_offspring = fitness

    return average_offspring


def reproduce(mutants_in_world, wildtypes_in_world):
    """
    Generates individuals for mutants and wildtypes.
    """
    for i in iteration_list:
        total_population = mutants_in_world[i] + wildtypes_in_world[i]
        expected_mutants = expected_offspring(deme_deterioration_state[i], total_population,
                                              carrying_capacities[i], True)
        expected_wildtypes = expected_offspring(deme_deterioration_state[i], total_population,
                                                carrying_capacities[i], False)
        mutants_in_world[i] = np.random.poisson(mutants_in_world[i] * expected_mutants)
        wildtypes_in_world[i] = np.random.poisson(wildtypes_in_world[i] * expected_wildtypes)


def generate_new_mutants(wildtypes):
    """
    Generates new mutants at every generation.
    """
    new_mutants = zero_maker(number_of_demes)
    if WINDOW_OF_MUTATION[0] < generation < WINDOW_OF_MUTATION[1]:
        for i in iteration_list:
            if wildtypes[i] > 0:
                new_mutants[i] = np.random.binomial(wildtypes[i], mutation_rate)

    return new_mutants


def create_pool():
    """
    Creates pool of migrants (for the island model).
    """
    pool = [0, 0]   # the pool contains the number of mutants and the number of wildtypes.
    mutants_in_pool = []
    wildtypes_in_pool = []
    for i in iteration_list:
        mutants_migrating = np.random.binomial(list_of_mutants[i], migration_rate)
        wildtypes_migrating = np.random.binomial(list_of_wildtypes[i], migration_rate)
        list_of_mutants[i] = list_of_mutants[i] - mutants_migrating
        list_of_wildtypes[i] = list_of_wildtypes[i] - wildtypes_migrating
        mutants_in_pool.append(mutants_migrating)
        wildtypes_in_pool.append(wildtypes_migrating)

    pool[0] = sum(mutants_in_pool)
    pool[1] = sum(wildtypes_in_pool)
    return pool


def assign_individuals_in_demes(pool):
    """
    Takes the pool of migrants generated with 'create_pool()' and assigns to each individual a new deme (for the island model).
    """
    # We create an array with the distribution of the individuals in the pool
    distribution_mutants = np.random.multinomial(pool[0], [1. / number_of_demes] * number_of_demes, 1)
    distribution_wildtypes = np.random.multinomial(pool[1], [1. / number_of_demes] * number_of_demes, 1)
    for i in iteration_list:
        list_of_mutants[i] = list_of_mutants[i] + distribution_mutants[0][i]
        list_of_wildtypes[i] = list_of_wildtypes[i] + distribution_wildtypes[0][i]


def short_range_migration():
    """
    This function takes care of migration for the stepping stone model.
    """
    # we have to send migrants to the right and to the left
    mutants_right = [0] * number_of_demes
    mutants_left = [0] * number_of_demes
    wildtypes_right = [0] * number_of_demes
    wildtypes_left = [0] * number_of_demes
    for i in iteration_list:
        mutants_migrating = np.random.binomial(list_of_mutants[i], migration_rate)
        wildtypes_migrating = np.random.binomial(list_of_wildtypes[i], migration_rate)

        # attribute migrants for deme 1 (reflecting walls)
        if i == 0:
            mutants_right[i] = np.random.binomial(mutants_migrating, 0.5)
            wildtypes_right[i] = np.random.binomial(wildtypes_migrating, 0.5)
            mutants_left[i] = 0
            wildtypes_left[i] = 0
            list_of_mutants[i] = list_of_mutants[i] - mutants_right[i]
            list_of_wildtypes[i] = list_of_wildtypes[i] - wildtypes_right[i]
        # attribute migrants for last deme (reflecting walls)
        elif i == number_of_demes - 1:
            mutants_right[i] = 0
            wildtypes_right[i] = 0
            mutants_left[i] = np.random.binomial(mutants_migrating, 0.5)
            wildtypes_left[i] = np.random.binomial(wildtypes_migrating, 0.5)
            list_of_mutants[i] = list_of_mutants[i] - mutants_left[i]
            list_of_wildtypes[i] = list_of_wildtypes[i] - wildtypes_left[i]
        # attribute migrants in all other demes
        else:
            mutants_left[i] = np.random.binomial(mutants_migrating, 0.5)
            mutants_right[i] = mutants_migrating - mutants_left[i]
            wildtypes_left[i] = np.random.binomial(wildtypes_migrating, 0.5)
            wildtypes_right[i] = wildtypes_migrating - wildtypes_left[i]
            list_of_mutants[i] = list_of_mutants[i] - mutants_migrating
            list_of_wildtypes[i] = list_of_wildtypes[i] - wildtypes_migrating

    for i in iteration_list:
        # finally, update populations in every deme.
        if i == 0:
            list_of_mutants[i] = list_of_mutants[i] + mutants_left[i + 1]
            list_of_wildtypes[i] = list_of_wildtypes[i] + wildtypes_left[i + 1]
        elif i == number_of_demes - 1:
            list_of_mutants[i] = list_of_mutants[i] + mutants_right[i - 1]
            list_of_wildtypes[i] = list_of_wildtypes[i] + wildtypes_right[i - 1]
        else:
            list_of_mutants[i] = list_of_mutants[i] + mutants_left[i + 1] + mutants_right[i - 1]
            list_of_wildtypes[i] = list_of_wildtypes[i] + wildtypes_left[i + 1] + wildtypes_right[i - 1]


def migrate(mutants_in_world, wildtypes_in_world):
    """
    If global, call pooling + assignment, if local call short_range_migration.
    """
    if isGlobal:
        new_pool = create_pool()  # (mutants_in_world, wildtypes_in_world)
        assign_individuals_in_demes(new_pool)  # , mutants_in_world, wildtypes_in_world)
    else:
        short_range_migration()  # (mutants_in_world, wildtypes_in_world)


def down_regulate_density(mutants_in_world, wildtypes_in_world):
    """
    Function to down regulate deme density if population after all other processes is too large.
    """
    total_population = zero_maker(number_of_demes)
    mutant_frequencies = zero_maker(number_of_demes)
    for i in iteration_list:
        total_population[i] = mutants_in_world[i] + wildtypes_in_world[i]
        if total_population[i] > 0:
            mutant_frequencies[i] = float(mutants_in_world[i]) / total_population[i]

        if total_population[i] > carrying_capacities[i]:
            number_of_dead = total_population[i] - carrying_capacities[i]
            dead_mutants = np.random.binomial(number_of_dead, mutant_frequencies[i])
            dead_wildtypes = number_of_dead - dead_mutants
            mutants_in_world[i] = max(mutants_in_world[i] - dead_mutants, 0)
            wildtypes_in_world[i] = max(wildtypes_in_world[i] - dead_wildtypes, 0)


def up_regulate_density(mutants_in_world, wildtypes_in_world):
    """
    Function to up regulate deme density if population after all other processes is too small (only in undeteriorated deme).
    """
    total_population = zero_maker(number_of_demes)
    mutant_frequencies = zero_maker(number_of_demes)
    for i in iteration_list:
        total_population[i] = mutants_in_world[i] + wildtypes_in_world[i]
        if total_population[i] > 0:
            mutant_frequencies[i] = float(mutants_in_world[i]) / total_population[i]

        if not deme_deterioration_state[i]:           # Up regulation only occurs in non-deteriorated state (when False)
            if total_population[i] < carrying_capacities[i]:
                new_total_population = np.random.poisson(carrying_capacities[i])
                mutants_in_world[i] = np.random.binomial(new_total_population, mutant_frequencies[i])
                wildtypes_in_world[i] = max(new_total_population - mutants_in_world[i], 0)


def is_rescued(percentage_threshold):
    """
    Flag function to determine if rescue has been reached.

    Condition for rescue: if mutants have attained a certain threshold (in terms of percentage carrying capacity in the whole habitat (cf Uecker)
    """
    if generation > BURNING_PHASE:
        if sum(list_of_mutants) >= percentage_threshold * total_carrying_capacity:
            return True
        else:
            return False
    else:
        return False


"""
SIMULATION STARTS HERE
"""

start_time = time.time()

# download the parameters
file_of_parameters = open(parameters_file, 'r')
parameters_to_read = np.loadtxt(file_of_parameters, skiprows=1, delimiter='\t')
file_of_parameters.close()

# Create output file.
header = [['TotalGenerations', 'Demes', 'TotalKappa', 'migration', 'isGlobal', 'mutation', 'frequency', 'growth',
           's', 'r', 'z', 'replicates', 'Rescue', 'Error']]
output = open('%s.txt' % output_file, 'w')
np.savetxt(output, header, fmt='%s')
output.close()

for line in parameters_to_read:
    """
    Definition of parameters.
    """
    [number_of_generations, number_of_demes, total_carrying_capacity, migration_rate, isGlobal, mutation_rate,
     initial_frequency, growth_rate, selection_against, stress, selection_for, replicates,
     probability_of_rescue, confidence_interval] = line

    replicates = int(replicates)
    number_of_demes = int(number_of_demes)

    epoch = int(number_of_generations / number_of_demes)     # epoch = number_of_generations

    iterate_over_replicates = np.linspace(1., replicates, replicates)

    total_replicate_time = int(BURNING_PHASE + epoch * number_of_demes + BURNING_OFF)
    iterate_over_generations = np.linspace(1., total_replicate_time, total_replicate_time)

    deme_carrying_capacity = math.ceil(total_carrying_capacity / number_of_demes)
    carrying_capacities = [deme_carrying_capacity] * number_of_demes
    iteration_list = list(range(number_of_demes))

    WINDOW_OF_MUTATION = [0, total_replicate_time]    # This is the window of time within which a mutation can occur

    if not STANDING_GENETIC_VARIATION:
        initial_frequency = 0.0

    result_of_replicate = []  # this keeps track of rescue events.

    """
    Start of a replicate.
    """
    for replicate in iterate_over_replicates:
        has_survived_yet = False

        # The whole simulation manipulates lists: every deme has an attributed list of wildtypes and an attributed list of mutants.
        list_of_populations = [deme_carrying_capacity] * number_of_demes

        list_of_mutants = []
        for i in iteration_list:
            mutants_in_deme = math.ceil(list_of_populations[i] * initial_frequency)
            list_of_mutants.append(mutants_in_deme)

        list_of_wildtypes = []
        for i in iteration_list:
            wildtypes_in_deme = list_of_populations[i] - list_of_mutants[i]
            list_of_wildtypes.append(wildtypes_in_deme)

        deme_deterioration_state = [False] * number_of_demes

        for generation in iterate_over_generations:
            if has_survived_yet:
                break

            deteriorate(generation, IS_RANDOM)

            reproduce(list_of_mutants, list_of_wildtypes)

            list_of_new_mutants = generate_new_mutants(list_of_wildtypes)

            total_after_reproduction = []

            for i in iteration_list:
                if list_of_new_mutants[i] > list_of_wildtypes[i]:
                    list_of_new_mutants[i] = list_of_wildtypes[i]

                list_of_mutants[i] += int(list_of_new_mutants[i])
                list_of_wildtypes[i] -= int(list_of_new_mutants[i])
                total_after_reproduction.append(list_of_mutants[i] + list_of_wildtypes[i])

            migrate(list_of_mutants, list_of_wildtypes)

            if DENSITY_REGULATION:
                """
                These are definitely redundant, but some redundancy never hurt anyone...
                """
                down_regulate_density(list_of_mutants, list_of_wildtypes)
                up_regulate_density(list_of_mutants, list_of_wildtypes)

            for i in iteration_list:
                list_of_populations[i] = list_of_mutants[i] + list_of_wildtypes[i]

            if sum(list_of_populations) == 0:
                break

            has_survived_yet = is_rescued(THRESHOLD)

            # we assume that rescue is reached if population still alive after burning-off period.
            if generation == total_replicate_time:
                has_survived_yet = True

        if has_survived_yet:
            result_of_replicate.append(True)

    """
    When simulation gets here, the list of result_of_replicate is filled with T (rescue) and F (extinction).
    What follows uses the list to give rescue percentages and CIs.
    """
    final_probability_of_rescue = sum(result_of_replicate) / replicates
    final_confidence_interval = math.fabs(
        -2.57 * math.sqrt(final_probability_of_rescue * (1 - final_probability_of_rescue) / replicates))

    # Saves parameters and results together in one file.
    parameters_to_append = [[number_of_generations, number_of_demes, total_carrying_capacity, migration_rate,
                             isGlobal, mutation_rate, initial_frequency, growth_rate, selection_against,
                             stress, selection_for, replicates,
                             final_probability_of_rescue, final_confidence_interval]]

    output = open('%s.txt' % output_file, 'a')
    np.savetxt(output, parameters_to_append, delimiter='\t', fmt='%.5f')
    output.close()

print('time of execution: {}'.format(time.time() - start_time))
