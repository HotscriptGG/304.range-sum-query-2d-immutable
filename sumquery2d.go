package sumquery2d

import "time"

type NumMatrix struct {
	matrix [][]int
}

func Constructor(matrix [][]int) NumMatrix {
	for row := 0; row < len(matrix); row++ {
		for i := 1; i < len(matrix[row]); i++ {
			matrix[row][i] += matrix[row][i-1]
		}
	}
	return NumMatrix{matrix: matrix}
}

func (nm *NumMatrix) SumRegion(row1 int, col1 int, row2 int, col2 int) int {
	sum := 0

	for r := row1; r <= row2; r++ {
		time.Sleep(200 * time.Millisecond)
		if col1 == 0 {
			sum += nm.matrix[r][col2]
		} else {
			sum += nm.matrix[r][col2] - nm.matrix[r][col1-1]
		}

	}

	return sum
}
