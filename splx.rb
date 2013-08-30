class Float
	def neg; -self end
	def int?; self.rationalize.denominator == 1 end
end

class Array
	def index_of_min; self.find_index(self.min) end
	def index_of_max; self.find_index(self.max) end
	def butlast; self.take([self.length-1,0].max) end
	def exists?(&pred); self.count(&pred) > 0 end
	def forall?(&pred); self.count(&pred) == self.length end
	def firstp(&pred); self.select(&pred).first end
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

	def self.column_vec(a, j); a.transpose[j] end

	def self.solution(a, b)
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
		[sol, feasible]
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
		sol, feasible = MatrixHelpers.solution(a, b)
		"Solution x=" + sol.inspect + "\nObjective f=" + f.inspect + "\nFeasible? " +
			(feasible ? "yes" : "no")
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
	def self.iterate!(t)
		pc = t.last.butlast.index_of_min
		pr = ((0..t.length-2).map {|i| t[i][pc] > 0 ? t[i].last/t[i][pc] : Float::INFINITY}).index_of_min

		return :succ if not t.last[pc] < 0
		return :fail if not pr

		SplxCommon.ero_transform(t, pr, pc)

		return :unfinished
	end
end

module SplxDual
	def self.iterate!(t)
		pr = t.transpose[t[0].length-1].butlast.index_of_min
		pc = ((0..t[0].length-2).map {|j| t[pr][j] < 0 ? t.last[j]/t[pr][j] : -Float::INFINITY}).index_of_max

		return :succ if not t[pr].last < 0
		return :fail if not pc

		SplxCommon.ero_transform(t, pr, pc)

		return :unfinished
	end
end

module LPSolver
	def self.show_step(stepno); puts "Step #{stepno}"; stepno+1 end

	def self.solve(a,b,c,f)
		ExampleProblem.solve({a:a,b:b,c:c,f:f})
	end

	def self.solve(p, verbose = true)
		if verbose
			Helpers.display_progress(p)
			stepno = show_step(0)
		end

		while true
			sol, feasible = MatrixHelpers.solution(p[:a], p[:b])
			t = MatrixHelpers.merge_matrices(p[:a],p[:b],p[:c],p[:f])
			state = feasible ? SplxPrimal.iterate!(t) : SplxDual.iterate!(t)
			p = MatrixHelpers.disperse_tableau(t)
			case state
				when :succ
					puts "Found optimal solution" if verbose
					return MatrixHelpers.solution(p[:a], p[:b])[0]
				when :fail
					puts "Failed" if verbose
					return nil
				when :unfinished
					if verbose
						Helpers.display_progress(p)
						stepno = show_step(stepno)
					end
			end
		end
	end
end

def main
	p1 = Hash.new
	p1[:a] = [[1.0, 1.0, 1.0, 0.0, 0.0],
			  [6.0, 9.0, 0.0, 1.0, 0.0],
			  [0.0, 1.0, 0.0, 0.0, 1.0]]
	p1[:b] = [100.0, 720.0, 60.0]
	p1[:c] = [10.0, 20.0, 0.0, 0.0, 0.0].map &:neg
	p1[:f] = [0.0]
	puts LPSolver.solve(p1, false).inspect

	p2 = Hash.new
	p2[:a] = [[-1.0, -1.0, 1.0, 0.0, 0.0],
			  [-3.0, -1.0, 0.0, 1.0, 0.0],
			  [1.0, 1.0, 0.0, 0.0, 1.0]]
	p2[:b] = [-8.0, -12.0, 10.0]
	p2[:c] = [-2.0, -1.0, 0.0, 0.0, 0.0]
	p2[:f] = [0.0]
	puts LPSolver.solve(p2, false).inspect
end

main

# unfinished. todo: hammock driven development
module IPSolver
	def self.integer?(x); x.forall? &:int? end
	def self.branch_i(x); x.firstp &:int? end

	def self.branch(p)
		branch_v = xopt[branch_i(xopt)]
	end

	def self.solve(p, verbose = true)
		xopt = LPSolver.solve(p)
		return xopt if integer?(xopt)
		p1, p2 = branch(p)
	end
end