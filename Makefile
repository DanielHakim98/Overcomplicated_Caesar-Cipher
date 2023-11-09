# Run!
filename := caesar_cipher

start: $(filename)
	target/$(filename)

# Create binary file
caesar_cipher: $(filename).o
	ld target/$(filename).o -o target/$(filename)

# Create object file
caesar_cipher.o: 
	mkdir -p target/
	as $(filename).s -o target/$(filename).o

# This one to clean up build files
clean:
	rm target/$(filename).o target/$(filename)