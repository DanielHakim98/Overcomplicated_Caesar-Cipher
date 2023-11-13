# Run!
filename := caesar_cipher
aux_file := shift_character
dependecy_file := constants


# binary generated needs two argument
# data: string to be shifted
# shifter: move count from its original number
# Ex: caesar_cipher('a', 1) = 'b'
# 'a' = 65 in ASCII
# 'b' = 66 in ASCII
start: $(filename)
	@target/$(filename) '$(data)' $(shifter)

# Create binary file
$(filename): $(filename).o $(aux_file).o
	@ld target/$(filename).o target/$(aux_file).o -o target/$(filename)

# Create object main file
$(filename).o: $(aux_file).o $(dependecy_file).s
	@mkdir -p target/
	@as $(filename).s -o target/$(filename).o

# Create dependecies first before main file
$(aux_file).o: $(dependecy_file).s
	@mkdir -p target/
	@as $(aux_file).s -o target/$(aux_file).o

# This one to clean up build files
clean:
	@rm target/$(filename).o target/$(filename)
	@rm target/$(aux_file).o

# For testing assembly program
test: target/$(filename)
	cargo test