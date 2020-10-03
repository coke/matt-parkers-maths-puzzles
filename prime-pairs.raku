#!/usr/bin/env raku 

# https://www.think-maths.co.uk/primepairs

# Given the numbers from one to nine, put them in order so that each pair
# sums to a prime number

# What numbers go into the list?
my $min = 1;
my $max = 10;

# How many do we put into the sum?
# TODO: make it work with more than 2
my $at-a-time = 2;

# For all the combinations, take only those that sum to a prime.
my $tuples = ($min..$max).combinations($at-a-time).grep(*.sum.is-prime);

# Are there any paths through the tuples that let us use each number once?
# for N numbers taken M at a time, we'd need N-M+1 tuples (e.g 9-1, we'd need 8A

my @paths = $tuples.combinations($max-$at-a-time + 1);

for @paths -> $path {
    # Throw the tuples into a bag and count the digits...
    my $bag = $path.List.flat.Bag;

    # In every valid path, $at-a-time digits must appear once, the remaining digits must appear twice.
    # Turn the counts from the Bag... into a another Bag - should have a key of 1 == 2, a key of 2 == the remainder, and nothing else.
    my $count-bag = $bag.values.Bag;
    next unless $count-bag.AT-KEY(1) == 2;
    next unless $count-bag.AT-KEY(2) == $max - 2;
    my $result = walk($path, $bag);
    say $result.join(', ') if $result;
}

# Walk the path, from start to end
sub walk($path is copy, $bag) {
    # Get the smaller of the numbers that only appears once.
    # (otherwise hash randomization means we don't get repeatable results)
    my $step = $bag.pairs.grep(*.value == 1).map(*.key).min;
    my @result;
    # loop, finding the next tuple that has that element.
    @result.push: $step;
    while $path {
        my $tuple = $path.first({$_[0] == $step or $_[1] == $step});
        # Some paths have dead ends; if we didn't find the next tuple, we're in one, jump to next
        return Nil unless $tuple;
        $path = $path.grep({!($_[0] == $tuple[0] && $_[1] == $tuple[1])});
        $step = $tuple[0] == $step ?? $tuple[1] !! $tuple[0];
        @result.push: $step;
    }
    return @result
}
