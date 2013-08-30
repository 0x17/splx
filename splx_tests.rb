require_relative 'splx'
require 'test/unit'

class ArrayExtensionsTest < Test::Unit::TestCase
	def test_index_of_min
		assert_equal(3, [3,7,8,2].index_of_min)
	end
	def test_butlast
		assert_equal([1,8], [1,8,5].butlast)
		assert_equal([], [2].butlast)
	end
	def test_exists?
		assert_equal(true, [1,2,3].exists? {|i| i==1})
		assert_equal(false, [1,3,5].exists? {|i| i.even?})
		assert_equal(false, [].exists? {|i| true})
	end
	def test_forall?
		assert_equal(true, [2,4,8,16,32,64].forall? {|i| i.even?})
		assert_equal(false, [1,2,4,8,16,32,64].forall? {|i| i.even?})
	end
end

class MatrixHelpersTest < Test::Unit::TestCase
	def test_merge_matrices
		expected_t = [[1,2,3],[4,5,6],[7,8,9]]
		actual_t = MatrixHelpers.merge_matrices([[1,2],[4,5]], [3,6], [7,8], [9])
		assert_equal(expected_t, actual_t)
	end
	def test_disperse_tableau
		expected_m = {a: [[1,2],[4,5]], b: [3,6], c: [7,8], f: [9]}
		actual_m = MatrixHelpers.disperse_tableau([[1,2,3],[4,5,6],[7,8,9]])
		assert_equal(actual_m, expected_m)
	end
end

class HelpersTest < Test::Unit::TestCase
	def test_solution_str
		actual_s = Helpers.solution_str([[3,0,1],[8,1,0]],[4,5],[40])
		assert_equal("Solution x=[0, 5, 4]\nObjective f=[40]\nFeasible? yes", actual_s)
		actual_s = Helpers.solution_str([[3,0,1],[8,1,0]],[-4,5],[40])
		assert_equal("Solution x=[0, 5, -4]\nObjective f=[40]\nFeasible? no", actual_s)
	end
end

class IPSolverTest < Test::Unit::TestCase
	def test_integer?
		assert_equal(true, IPSolver.integer?([1,2,3,4,5]))
		assert_equal(false, IPSolver.integer?([2.5, 2, 4, 5]))
	end
end