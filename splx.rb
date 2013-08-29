class Float; def neg; -self end end

class Array
	def index_of_min; self.find_index(self.min) end
	def index_of_max; self.find_index(self.max) end
	def butlast; self.take([self.length-1,0].max) end
end

class Hash
	def to_array(*keys); keys.map {|key| self[key]} end
end

module MatrixHelpers
	def self.merge_matrices(a, b, c, f)
		Array.new(a.length+1) do |i|
			Array.new(a[0].length+1) do |j|
				if i < a.length && j < a[0].length
					a[i][j]
				elsif i == a.length && j < a[0].length
					c[j]
				elsif i == a.length && j == a[0].length
					f.first
				else
					b[i]
				end
			end
		end
	end

	def self.disperse_tableau(t)
		a = (t.map {|row| row.butlast}).butlast
		b = (t.map &:last).butlast
		{:a => a, :b => b, :c => t.last.butlast, :f => [t.last.last]}
	end

	def self.column_vec(a, j)
		a.map { |row| row[j] }
	end
end

module SplxCommon
	def self.ero_transform(t, pr, pc)
		pelem = t[pr][pc]
		t[pr].map! { |e| e * 1.0 / pelem }

		(0..t.length-1).reject {|i| i == pr }.each do |i|
			toelim = t[i][pc]
			(0..t[0].length-1).each do |j|
				t[i][j] -= t[pr][j] * toelim
			end
		end
	end
end

module SplxPrimal
	def self.pivot_col(c); c.index_of_min end

	def self.pivot_row(a, b, j)
		(((0..a.length-1).select {|i| a[i][j] > 0 }).map {|i| b[i]/a[i][j]}).index_of_min
	end

	def self.iterate_unified!(t)
		pc = t.last.butlast.index_of_min
		pr = (((0..t.length-2).select {|i| t[i][pc] > 0 }).map {|i| t[i].last/t[i][pc]}).index_of_min

		return :succ if not t.last[pc] < 0
		return :fail if not pr

		SplxCommon.ero_transform(t, pr, pc)

		return :unfinished
	end

	def self.iterate!(a, b, c, f)
		pc = pivot_col(c)
		pr = pivot_row(a,b,pc)

		return :succ if not c[pc] < 0
		return :fail if not pr

		pelem = a[pr][pc]
		a[pr].map! { |e| e * 1.0 / pelem }
		b[pr] *= 1.0 / pelem

		(0..a.length-1).reject {|i| i == pr }.each do |i|
			toelim = a[i][pc]
			(0..a[0].length-1).each do |j|
				a[i][j] -= a[pr][j] * toelim
			end
			b[i] -= b[pr] * toelim
		end

		toelim = c[pc]
		(0..c.length-1).each do |j|
			c[j] -= a[pr][j] * toelim
		end
		f[0] -= b[pr] * toelim

		return :unfinished
	end
end

module SplxDual
	def self.iterate_unified!(t)
		pr = MatrixHelpers.column_vec(t, t[0].length-1).butlast.index_of_min
		pc = (((0..t[0].length).select {|j| t[pr][j] < 0 }).map {|j| t.last[j]/t[pr][j]}).index_of_max

		return :succ if not t[pr].last >= 0
		return :fail if not pc

		SplxCommon.ero_transform(t, pr, pc)

		return :unfinished
	end
end

module Helpers
	def self.pretty_print(a)
		for i in 0..a.length-1
			print "[ "
			for j in 0..a[0].length-1
				print a[i][j].to_s + " "
			end
			puts "]"
		end
	end

	def self.display_header; puts "-" * 45 end

	def self.display_progress(p)
		display_header
		puts "A="
		pretty_print(p[:a])
		puts "B=" + p[:b].inspect
		puts "C=" + p[:c].inspect
		puts "F=" + p[:f].inspect
		puts solution_str(p[:a],p[:b],p[:f])
	end

	def self.solution_str(a, b, f)
		sol = Array.new(a[0].length, 0)
		feasible = true
		for j in 0..sol.length-1
			bv = true
			sum = 0
			v = 0
			for i in 0..a.length-1
				if a[i][j] < 0 && a[i][j] > 1
					bv = false
				end
				sum += a[i][j]
				if a[i][j] == 1
					v = b[i]
				end
			end
			bv &= (sum == 1)
			if bv
				sol[j] = v
				feasible &= (v >= 0)
			end
		end
		"Solution x=" + sol.inspect + "\nObjective f=" + f.inspect + "\nFeasible? " +
			(feasible ? "yes" : "no")
	end
end

module ExampleProblem
	def self.show_step(stepno); puts "Step #{stepno}"; stepno+1 end

	def self.solve(p)
		Helpers.display_progress(p)
		stepno = show_step(0)

		while true
			t = MatrixHelpers.merge_matrices(p[:a],p[:b],p[:c],p[:f])
			state = SplxPrimal.iterate_unified!(t)
			p = MatrixHelpers.disperse_tableau(t)
			case state
				when :succ
					puts "Found optimal solution"
					return
				when :fail
					puts "Failed"
					return
				when :unfinished
					Helpers.display_progress(p)
					stepno = show_step(stepno)
			end
		end
	end
end

a = [[1.0, 1.0, 1.0, 0.0, 0.0],
	 [6.0, 9.0, 0.0, 1.0, 0.0],
	 [0.0, 1.0, 0.0, 0.0, 1.0]]
b = [100.0, 720.0, 60.0]
c = [10.0, 20.0, 0.0, 0.0, 0.0].map &:neg
f = [0.0]
ExampleProblem.solve({a:a,b:b,c:c,f:f})
