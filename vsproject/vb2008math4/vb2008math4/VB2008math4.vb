Module VB2008math4
    Function Expressions(minNum As Int64, maxNum As Int64) As List(Of String)
        Dim ls As New List(Of String)
        Dim num = minNum.ToString
        If (minNum = maxNum) Then
            ls.Add(num)
        Else
            For Each subExpr In Expressions(minNum + 1, maxNum)
                ls.Add(num + "+" + subExpr)
                ls.Add(num + "*" + subExpr)
            Next
        End If

        Return ls
    End Function

    Function MakeResult(expr As String) As Tuple(Of Int64, String)
        Dim result = Convert.ToInt64(New Data.DataTable().Compute(expr, Nothing))
        Return Tuple.Create(result, expr)
    End Function

    Sub PrintSums(minNum As Int64, maxNum As Int64)
        Dim results As New List(Of Tuple(Of Int64, String))
        For Each expr In Expressions(minNum, maxNum)
            results.Add(MakeResult(expr))
        Next

        For Each exprPair In results.OrderBy(Function(t) t.Item1).ToArray()
            Console.WriteLine(exprPair.Item1.ToString + " = " + exprPair.Item2)
        Next
    End Sub

    Sub PrintMatchedSums(minLeft As Int64, maxLeft As Int64, minRight As Int64, maxRight As Int64)
        For Each leftExpr In Expressions(minLeft, maxLeft)
            Dim l = MakeResult(leftExpr)
            For Each rightExpr In Expressions(minRight, maxRight)
                Dim r = MakeResult(rightExpr)
                If (l.Item1 = r.Item1) Then
                    Console.WriteLine(l.Item2 + " == " + r.Item2)
                End If
            Next
        Next
    End Sub

    Sub Main()
        PrintSums(1, 4)
        PrintMatchedSums(1, 5, 2, 6)
    End Sub
End Module
