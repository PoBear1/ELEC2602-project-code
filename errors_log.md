# A log of errors, so that I can actually have a thought process.

## Error \#1: adding

So I was trying out my processor so that I wouldn't flop down in front of the tutors, but I was observing the addition output and I was getting something extremely weird. Here's a table of values with Rr &larr; Rr + Rd:

|Rr|Rd|Sum|
|:-:|:-:|:---:|
|1|1|1|
|2|1|4|
|2|2|2|
|1|2|2|
|3|1|6|
|3|2|6|
|3|3|3|
|2|3|4|
|1|3|2|

A pattern emerges: What should have been sum is now 2 * Rr if Rr != Rd and Rr if Rr == Rd. This gave me a massive shock; maybe I should have re-read the ALU module code. The problem with this was that testing the ADD/ADC code, nothing felt off at all. I ordered Claude to write me testbenches for both and test them, and no tests failed. Something must have happened, and I believe it may be with mapping problems. Just to check, I moved alu_mode into the main if statements for add, and modified the alu_mode. Turns out it might have had been because some timing error in the middle; add_x was registering the right thing, but out was not. 

Eventually after playing around I realised the following error: the ALU was not updating when add_x updated, causing a small lag error that cooked the whole system. After I fixed that the system finally worked, with an error bugging me the whole afternoon (a sub would cook the bus for some reason) also fixed with this issue.

