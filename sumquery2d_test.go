package sumquery2d

import "testing"

func TestNumMatrix_SumRegion(t *testing.T) {
	type args struct {
		row1 int
		col1 int
		row2 int
		col2 int
	}
	type Test struct {
		name string
		nm   NumMatrix
		args args
		want int
	}

	matrix := [][]int{
		{3, 0, 1, 4, 2},
		{5, 6, 3, 2, 1},
		{1, 2, 0, 1, 5},
		{4, 1, 0, 1, 7},
		{1, 0, 3, 0, 5},
	}
	tests := Test{
		name: "case1",
		nm:   Constructor(matrix),
		args: args{2, 1, 4, 3},
		want: 8,
	}

	t.Run(tests.name, func(t *testing.T) {
		if got := tests.nm.SumRegion(tests.args.row1, tests.args.col1, tests.args.row2, tests.args.col2); got != tests.want {
			t.Errorf("NumMatrix.SumRegion() = %v, want %v", got, tests.want)
		}
	})
}

func BenchmarkNumMatrix_SumRegion(b *testing.B) {
	matrix := [][]int{
		{3, 0, 1, 4, 2},
		{5, 6, 3, 2, 1},
		{1, 2, 0, 1, 5},
		{4, 1, 0, 1, 7},
		{1, 0, 3, 0, 5},
	}

	nm := Constructor(matrix)
	for i := 0; i < b.N; i++ {
		nm.SumRegion(2, 1, 4, 3)
		nm.SumRegion(1, 1, 2, 2)
		nm.SumRegion(1, 2, 2, 4)
	}
}
