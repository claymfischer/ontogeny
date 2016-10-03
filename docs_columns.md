# Color-code columnar data

This is a utility that helps make tab-separated data easier to view on the command line.

![Column color coding](images/columns/columns_usage.png)

---

This is what it looks like when viewing columnar-data on the command line. It can be difficult to ascertain what belongs to which column.

`$ cat example.tsv`

![Example column coloring](/images/columns/columns_example2.png)


By passing through a simple grep loop, we can colorize our column output.

`$ columns example.tsv`

![Example column coloring](/images/columns/columns_example2_colored.png)

---

Another example.

![Column color coding](images/columns/columns_example.png)


![Column color coding](images/columns/columns_example_colored.png)
