using LazyViews
using Base.Test

# write your own tests here
@test 1 == 1

const fs = [
  x -> x,
  x -> 2*x,
  x -> sin(x),
  x -> x^3 + 3*x - 2,
  x -> sqrt(x)
];

const _NFPTESTS = 5000;
pdone = 10;

println("Floating point, $_NFPTESTS tests...");
for n=1:_NFPTESTS
  d   =   rand(1:5);
  ns  =   rand(1:25, d);
  a   =   rand(ns...);
  for f in fs
    mv    =   MapView{Float64, d}(f, a);
    lv    =   LazyView{Float64, d}(f, a);
    lvlv  =   LazyView{Float64, d}(f, lv);
    @test(mv == map(f, a));
    @test(lv == map(f, a));
    @test(map(f, a) == mv);
    @test(map(f, a) == lv);
    @test(mv == lv);
    @test(lvlv == map(f, map(f, a)));
  end
  if (n % (_NFPTESTS / 10)) == 0
    print("$pdone%... ");
    pdone += 10;
  end
end
print_with_color(:green, "\nTEST PASSED.\n");

const cs = rand(-1e4:1e-9:1e4, 100);
const _SMTESTS = 100;
pdone = 10;

println("Scaler multiple, $_SMTESTS tests...");
for n=1:_SMTESTS
  d   =   rand(1:5);
  ns  =   rand(1:25, d);
  a   =   rand(ns...);
  for c in cs
    cv  =   CView{Float64, d}(c, a);
    lv  =   LazyView{Float64, d}(x -> c*x, a);
    @test(cv == map(x -> c*x, a));
    @test(cv == c * a);
    @test(c * a == cv);
    @test(cv == lv);
    @test((c * (c * a)) == (c * lv));
    @test((c * (c * a)) == (lv * c));
  end
  if (n % (_SMTESTS / 10)) == 0
    print("$pdone%... ");
    pdone += 10;
  end
end
print_with_color(:green, "\nTEST PASSED.\n");
