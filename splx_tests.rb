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
end

class HashExtensionsTest < Test::Unit::TestCase
	def test_to_array
		assert_equal([],{}.to_array())
		assert_equal([1,2,3], {a:1,b:3,c:2}.to_array(:a,:c,:b))
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

class SplxPrimalTest < Test::Unit::TestCase
	def test_pivot_col; assert_equal(1, SplxPrimal.pivot_col([-10, -20, 0, 0, 0])) end
	def test_pivot_row
		assert_equal(2, SplxPrimal.pivot_row([[1,2],[3,4],[5,6]], [9,6,5], 0))
		assert_equal(0, SplxPrimal.pivot_row([[1,2],[0,4],[0,6]], [9,6,5], 0))
		assert_equal(1, SplxPrimal.pivot_row([[1,2],[3,4],[-5,6]], [9,6,5], 0))
	end
	def test_iterate_unified
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
