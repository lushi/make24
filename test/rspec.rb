describe "mathematical expression validator regex" do
	let(:original_regex) {/\A\({0,3}\s*\d{1,2}\s*(\*|\+|-|\/)\s*\({0,2}\s*\d{1,2}\s*\)?\s*(\*|\+|-|\/)\s*\(?\s*\d{1,2}\s*\){0,2}\s*(\*|\+|-|\/)\s*\d{1,2}\s*\){0,3}\z/}
	let(:new_regex) { %r{
		(?<num> \d{1,2} ){0}
		(?<op> (\*|\+|-|\/) ){0}
		(?<openp> \({0,3} ){0}
		(?<closep> \){0,3} ){0}

		\A\g<openp>\s*\g<num>\s*\g<op>\s*\g<openp><num>\s*\g<closep>\s*\g<op>\s*\g<openp>\s*\g<num>\s*\g<closep>\s*\g<op>\s*\g<num>\s*\g<closep>\z
		}x }

		# \A\g<num>\s*\g<op>\s*\g<num>\s*\g<op>\s*\g<num>\s*\g<op>\s*\g<num>\z
		# }x }

	it "handles simple addition" do
		str = "1 + 1 + 1 + 1"
		str.match(new_regex).nil?.should == str.match(original_regex).nil?
	end

	it "rejects strings prefixed with junk content" do
		str = "abcgd1 + 1 + 1 + 1"
		str.match(new_regex).nil?.should == str.match(original_regex).nil?
	end

	it "rejects strings appended with junk content" do
		str = "1 + 1 + 1 + 1fdafhdjlahfj"
		str.match(new_regex).nil?.should == str.match(original_regex).nil?
	end

	it "rejects strings with junk content inserted" do
		str = "1 + 1 + fdhjalhfjdl1 + 1"
		str.match(new_regex).nil?.should == str.match(original_regex).nil?
	end

	it "handles numbers 1-10" do
		str = "10 + 1 + 1 + 10"
		str.match(new_regex).nil?.should == str.match(original_regex).nil?
	end

	it "handles all operations" do
		str = "1 * 1 / 1 - 1"
		str.match(new_regex).nil?.should == str.match(original_regex).nil?
	end

	it "handles spaces" do
		str = "1 *1/ 1- 1"
		str.match(new_regex).nil?.should == str.match(original_regex).nil?
	end

	it "handles parenthese" do
		str = "(1 + 1) / (1 - 1)"
		str.match(new_regex).nil?.should == str.match(original_regex).nil?
	end

	it "handles nested parenthese" do
		str = "((1+1)-1) / 1"
		str.match(new_regex).nil?.should == str.match(original_regex).nil?
	end

	it "handles wrongly placed parenthese" do
		str = ")1+1) + 1 + 1"
		str.match(new_regex).nil?.should == str.match(original_regex).nil?
	end

	it "handles wrongly placed parenthese 2" do
		str = "(1( + 1) * (1 - (1)"
		str.match(new_regex).nil?.should == str.match(original_regex).nil?
	end
end
