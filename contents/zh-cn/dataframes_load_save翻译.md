## 文件的加载和保存 {#sec:load_save}

只使用Julia程序中的数据而无法加载或保存它会十分限制我们的工作。因此，我们开始讲述如何将文件保存到磁盘和如何从磁盘加载文件。我们关注CSV数据格式（@sec:csv）和Excel数据格式（@sec:excel），因为它们是表格数据中最常见的数据格式。

### CSV {#sec:csv}

CSV，全称Comma-separated values，是非常有效的存储表格的数据格式。与其他数据存储文件相比，CSV 文件有两个优点。第一个优点，它能完全按照名称所示执行，即通过使用逗号“,”来分隔所存储的数值。

首字母缩写词也用作文件扩展名。因此，请确保使用“.csv”扩展名（例如“myfile.csv”）来保存文件。

 为了演示 CSV 文件的外观，我们可以先安装[`CSV.jl`](http://csv.juliadata.org/latest/)包：

```
julia> ]

pkg> add CSV
```

并通过以下命令来加载它：

```
using CSV
```

我们现在可以使用我们之前的数据：

```jl
sco("
grades_2020()
"; process=without_caption_label)
```

写入后，从文件中读取它：

```jl
@sc write_grades_csv()
```

```jl
sco("""
JDS.output_block_inside_tempdir() do # hide
path = write_grades_csv()
read(path, String)
end # hide
""")
```

在这里，我们还看到了 CSV 数据格式的第二个好处：可以使用简单的文本编辑器读取数据。这不同于许多其他数据格式，需要专门的软件，例如Excel。

CSV的运作非常美妙，但是如果我们的数据**包含逗号`,`**作为数值应该怎么办？如果我们直接把逗号写入为数据，这会使文件很难转换回表格。幸运的是，`CSV.jl` 能自动为我们处理这个麻烦。

考虑以下带逗号 `,`的数据：

```jl
@sco grades_with_commas()
```

如果我们写入这个，我们得到：

```jl
sco("""
JDS.output_block_inside_tempdir() do # hide
function write_comma_csv()
    path = "grades-commas.csv"
    CSV.write(path, grades_with_commas())
end
path = write_comma_csv()
read(path, String)
end # hide
""")
```

因此，`CSV.jl` 在包含逗号的值周围添加引号 `"` 。

解决此问题的另一种常见方法是将数据写入**t**ab-**s**eparated **v**alues (TSV) 格式的文件。这种做法要求数据不包含`tab`，这在大多数情况下成立。

另请注意，也可以使用简单的文本编辑器读取 TSV 文件，这些文件使用“.tsv”作为扩展名。

```jl
sco("""
JDS.output_block_inside_tempdir() do # hide
function write_comma_tsv()
    path = "grades-comma.tsv"
    CSV.write(path, grades_with_commas(); delim='\\t')
end
read(write_comma_tsv(), String)
end # hide
""")
```

CSV和TSV格式的文本文件 还可以使用其他分隔符，例如分号“；”、空格“\ ”，甚至是像“π”这样不寻常的东西。

```jl
sco("""
JDS.output_block_inside_tempdir() do # hide
function write_space_separated()
    path = "grades-space-separated.csv"
    CSV.write(path, grades_2020(); delim=' ')
end
read(write_space_separated(), String)
end # hide
""")
```

按照惯例，最好为文件提供特殊分隔符，例如给“.csv”文件以分号“;”作为数据间的分割。

加载CSV文件和加载`CSV.jl`是类似的。您可以使用`CSV.read`并指定您想要的输出格式。我们指定一个 `DataFrame`：

```jl
sco("""
JDS.inside_tempdir() do # hide
path = write_grades_csv()
CSV.read(path, DataFrame)
end # hide
"""; process=without_caption_label)
```

十分方便地，`CSV.jl`将自动为我们推断列的类型：

```jl
sco("""
JDS.inside_tempdir() do # hide
path = write_grades_csv()
df = CSV.read(path, DataFrame)
end # hide
"""; process=string, post=output_block)
```

对更复杂的数据也适用：

```jl
sco("""
JDS.inside_tempdir() do # hide
my_data = \"\"\"
    a,b,c,d,e
    Kim,2018-02-03,3,4.0,2018-02-03T10:00
    \"\"\"
path = "my_data.csv"
write(path, my_data)
df = CSV.read(path, DataFrame)
end # hide
"""; process=string, post=output_block)
```

这些关于CSV的基础知识可涵盖大多数的使用场景。想要查询更多的信息，请参考[`CSV.jl` documentation](https://csv.juliadata.org/stable)，特别是[`CSV.File` constructor docstring](https://csv.juliadata.org/stable/#CSV.File)。

### Excel {#sec:excel}

有多个 Julia 包可以读取 Excel 文件。在本书中，我们将只讲述[`XLSX.jl`](https://github.com/felipenoris/XLSX.jl)这个包，因为它是处理 Excel 数据的 Julia 生态系统中维护最积极的包。第二个好处是，`XLSX.jl`是用纯 Julia 编写的，这使我们可以轻松检查和了解幕后发生的事情。

通过以下命令加载`XLSX.jl` ：

```
using XLSX:
    eachtablerow,
    readxlsx,
    writetable
```

为了写入文件，我们为数据和列名定义了一个小辅助函数：

```jl
@sc write_xlsx("", DataFrame())
```

现在，我们可以轻松地将成绩写入 Excel 文件：

```jl
@sc write_grades_xlsx()
```

再将其读入，我们可以看到`XLSX.jl` 把数据放在类型`XLSXFile`钟， 我们可以像访问 `Dict` 一样访问所需的 `sheet`：

```jl
sco("""
JDS.inside_tempdir() do # hide
path = write_grades_xlsx()
xf = readxlsx(path)
end # hide
""")
```

```jl
s = """
    JDS.inside_tempdir() do # hide
    xf = readxlsx(write_grades_xlsx())
    sheet = xf["Sheet1"]
    eachtablerow(sheet) |> DataFrame
    end # hide
    """
sco(s; process=without_caption_label)
```

请注意，我们这里只讲了`XLSX.jl`的基础知识，这个包还涵盖很多更强大的用法和自定义使用。有关更多信息和选项，请参阅[`XLSX.jl` documentation](https://felipenoris.github.io/XLSX.jl/stable/).
