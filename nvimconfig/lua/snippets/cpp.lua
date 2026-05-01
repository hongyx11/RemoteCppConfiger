local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Basic C++ structure
  s("main", fmt([[
    #include <iostream>
    using namespace std;

    int main() {{
        {}
        return 0;
    }}
  ]], {
    i(1, "// Your code here")
  })),

  -- Class definition
  s("class", fmt([[
    class {} {{
    private:
        {}

    public:
        {}();
        ~{}();
        {}
    }};
  ]], {
    i(1, "ClassName"),
    i(2, "// Private members"),
    rep(1), -- Constructor name
    rep(1), -- Destructor name
    i(3, "// Public methods")
  })),

  -- Function definition
  s("func", fmt([[
    {} {}({}) {{
        {}
    }}
  ]], {
    c(1, {t("void"), t("int"), t("string"), t("double"), t("bool")}),
    i(2, "functionName"),
    i(3, ""),
    i(4, "// Function body")
  })),

  -- For loop
  s("for", fmt([[
    for ({} {} = {}; {} < {}; {}++) {{
        {}
    }}
  ]], {
    c(1, {t("int"), t("size_t"), t("auto")}),
    i(2, "i"),
    i(3, "0"),
    rep(2),
    i(4, "n"),
    rep(2),
    i(5, "// Loop body")
  })),

  -- Range-based for loop
  s("forr", fmt([[
    for (const auto& {} : {}) {{
        {}
    }}
  ]], {
    i(1, "item"),
    i(2, "container"),
    i(3, "// Loop body")
  })),

  -- While loop
  s("while", fmt([[
    while ({}) {{
        {}
    }}
  ]], {
    i(1, "condition"),
    i(2, "// Loop body")
  })),

  -- If statement
  s("if", fmt([[
    if ({}) {{
        {}
    }}
  ]], {
    i(1, "condition"),
    i(2, "// If body")
  })),

  -- If-else statement
  s("ife", fmt([[
    if ({}) {{
        {}
    }} else {{
        {}
    }}
  ]], {
    i(1, "condition"),
    i(2, "// If body"),
    i(3, "// Else body")
  })),

  -- If constexpr statement (C++17)
  s("ifc", fmt([[
    if constexpr ({}) {{
        {}
    }}
  ]], {
    i(1, "compile_time_condition"),
    i(2, "// Compile-time conditional code")
  })),

  -- If constexpr-else statement (C++17)
  s("ifce", fmt([[
    if constexpr ({}) {{
        {}
    }} else {{
        {}
    }}
  ]], {
    i(1, "compile_time_condition"),
    i(2, "// Compile-time if branch"),
    i(3, "// Compile-time else branch")
  })),

  -- Switch statement
  s("switch", fmt([[
    switch ({}) {{
        case {}:
            {}
            break;
        default:
            {}
            break;
    }}
  ]], {
    i(1, "variable"),
    i(2, "value"),
    i(3, "// Case body"),
    i(4, "// Default body")
  })),

  -- Try-catch block
  s("try", fmt([[
    try {{
        {}
    }} catch (const {}& {}) {{
        {}
    }}
  ]], {
    i(1, "// Try block"),
    i(2, "std::exception"),
    i(3, "e"),
    i(4, "// Catch block")
  })),

  -- Vector declaration
  s("vec", fmt([[
    std::vector<{}> {}({});
  ]], {
    i(1, "int"),
    i(2, "vec_name"),
    i(3, "")
  })),

  -- Map declaration
  s("map", fmt([[
    std::map<{}, {}> {}({});
  ]], {
    i(1, "int"),
    i(2, "string"),
    i(3, "map_name"),
    i(4, "")
  })),

  -- Include guards
  s("guard", fmt([[
    #ifndef {}_H
    #define {}_H

    {}

    #endif // {}_H
  ]], {
    i(1, "HEADER_NAME"),
    rep(1),
    i(2, "// Header content"),
    rep(1)
  })),

  -- Common includes
  s("inc", fmt([[
    #include <{}>
  ]], {
    c(1, {
      t("iostream"),
      t("vector"),
      t("string"),
      t("map"),
      t("algorithm"),
      t("memory"),
      t("fstream")
    })
  })),

  -- Namespace
  s("ns", fmt([[
    namespace {} {{
        {}
    }} // namespace {}
  ]], {
    i(1, "namespace_name"),
    i(2, "// Namespace content"),
    rep(1)
  })),

  -- Lambda function
  s("lambda", fmt([[
    auto {} = []({}) -> {} {{
        {}
    }};
  ]], {
    i(1, "lambda_name"),
    i(2, ""),
    i(3, "void"),
    i(4, "// Lambda body")
  })),

  -- Smart pointer
  s("unique", fmt([[
    std::unique_ptr<{}> {} = std::make_unique<{}>({});
  ]], {
    i(1, "Type"),
    i(2, "ptr_name"),
    rep(1),
    i(3, "")
  })),

  -- Shared pointer
  s("shared", fmt([[
    std::shared_ptr<{}> {} = std::make_shared<{}>({});
  ]], {
    i(1, "Type"),
    i(2, "ptr_name"),
    rep(1),
    i(3, "")
  })),

  -- MPI Functions
  s("mpiinit", fmt([[
    MPI_Init(&argc, &argv);
  ]], {})),

  s("mpifinalize", fmt([[
    MPI_Finalize();
  ]], {})),

  s("mpibarrier", fmt([[
    MPI_Barrier({});
  ]], {
    c(1, {t("MPI_COMM_WORLD"), i(1, "communicator")})
  })),

  s("mpirank", fmt([[
    int {};
    MPI_Comm_rank({}, &{});
  ]], {
    i(1, "rank"),
    c(2, {t("MPI_COMM_WORLD"), i(1, "communicator")}),
    rep(1)
  })),

  s("mpisize", fmt([[
    int {};
    MPI_Comm_size({}, &{});
  ]], {
    i(1, "size"),
    c(2, {t("MPI_COMM_WORLD"), i(1, "communicator")}),
    rep(1)
  })),

  s("mpisend", fmt([[
    MPI_Send({}, {}, {}, {}, {}, {});
  ]], {
    i(1, "data"),
    i(2, "count"),
    c(3, {t("MPI_INT"), t("MPI_DOUBLE"), t("MPI_CHAR"), i(1, "datatype")}),
    i(4, "dest"),
    i(5, "tag"),
    c(6, {t("MPI_COMM_WORLD"), i(1, "communicator")})
  })),

  s("mpirecv", fmt([[
    MPI_Recv({}, {}, {}, {}, {}, {}, &{});
  ]], {
    i(1, "data"),
    i(2, "count"),
    c(3, {t("MPI_INT"), t("MPI_DOUBLE"), t("MPI_CHAR"), i(1, "datatype")}),
    i(4, "source"),
    i(5, "tag"),
    c(6, {t("MPI_COMM_WORLD"), i(1, "communicator")}),
    i(7, "status")
  })),

  s("mpibcast", fmt([[
    MPI_Bcast({}, {}, {}, {}, {});
  ]], {
    i(1, "data"),
    i(2, "count"),
    c(3, {t("MPI_INT"), t("MPI_DOUBLE"), t("MPI_CHAR"), i(1, "datatype")}),
    i(4, "root"),
    c(5, {t("MPI_COMM_WORLD"), i(1, "communicator")})
  })),

  s("mpireduce", fmt([[
    MPI_Reduce({}, {}, {}, {}, {}, {}, {});
  ]], {
    i(1, "sendbuf"),
    i(2, "recvbuf"),
    i(3, "count"),
    c(4, {t("MPI_INT"), t("MPI_DOUBLE"), t("MPI_CHAR"), i(1, "datatype")}),
    c(5, {t("MPI_SUM"), t("MPI_MAX"), t("MPI_MIN"), i(1, "op")}),
    i(6, "root"),
    c(7, {t("MPI_COMM_WORLD"), i(1, "communicator")})
  })),

  s("mpiallreduce", fmt([[
    MPI_Allreduce({}, {}, {}, {}, {}, {});
  ]], {
    i(1, "sendbuf"),
    i(2, "recvbuf"),
    i(3, "count"),
    c(4, {t("MPI_INT"), t("MPI_DOUBLE"), t("MPI_CHAR"), i(1, "datatype")}),
    c(5, {t("MPI_SUM"), t("MPI_MAX"), t("MPI_MIN"), i(1, "op")}),
    c(6, {t("MPI_COMM_WORLD"), i(1, "communicator")})
  })),

  s("mpigather", fmt([[
    MPI_Gather({}, {}, {}, {}, {}, {}, {}, {});
  ]], {
    i(1, "sendbuf"),
    i(2, "sendcount"),
    c(3, {t("MPI_INT"), t("MPI_DOUBLE"), t("MPI_CHAR"), i(1, "sendtype")}),
    i(4, "recvbuf"),
    i(5, "recvcount"),
    c(6, {t("MPI_INT"), t("MPI_DOUBLE"), t("MPI_CHAR"), i(1, "recvtype")}),
    i(7, "root"),
    c(8, {t("MPI_COMM_WORLD"), i(1, "communicator")})
  })),

  s("mpiallgather", fmt([[
    MPI_Allgather({}, {}, {}, {}, {}, {}, {});
  ]], {
    i(1, "sendbuf"),
    i(2, "sendcount"),
    c(3, {t("MPI_INT"), t("MPI_DOUBLE"), t("MPI_CHAR"), i(1, "sendtype")}),
    i(4, "recvbuf"),
    i(5, "recvcount"),
    c(6, {t("MPI_INT"), t("MPI_DOUBLE"), t("MPI_CHAR"), i(1, "recvtype")}),
    c(7, {t("MPI_COMM_WORLD"), i(1, "communicator")})
  })),

  s("mpiscatter", fmt([[
    MPI_Scatter({}, {}, {}, {}, {}, {}, {}, {});
  ]], {
    i(1, "sendbuf"),
    i(2, "sendcount"),
    c(3, {t("MPI_INT"), t("MPI_DOUBLE"), t("MPI_CHAR"), i(1, "sendtype")}),
    i(4, "recvbuf"),
    i(5, "recvcount"),
    c(6, {t("MPI_INT"), t("MPI_DOUBLE"), t("MPI_CHAR"), i(1, "recvtype")}),
    i(7, "root"),
    c(8, {t("MPI_COMM_WORLD"), i(1, "communicator")})
  })),

  s("mpimain", fmt([[
    #include <mpi.h>
    #include <iostream>
    using namespace std;

    int main(int argc, char** argv) {{
        MPI_Init(&argc, &argv);
        
        int rank, size;
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        MPI_Comm_size(MPI_COMM_WORLD, &size);
        
        {}
        
        MPI_Finalize();
        return 0;
    }}
  ]], {
    i(1, "// Your MPI code here")
  })),

  s("mpiwtime", fmt([[
    double {} = MPI_Wtime();
    {}
    double {} = MPI_Wtime();
    double {} = {} - {};
  ]], {
    i(1, "start_time"),
    i(2, "// Timed code"),
    i(3, "end_time"),
    i(4, "elapsed_time"),
    rep(3),
    rep(1)
  })),

  s("mpiif", fmt([[
    if (rank == {}) {{
        {}
    }}
  ]], {
    i(1, "0"),
    i(2, "// Master process code")
  })),
}