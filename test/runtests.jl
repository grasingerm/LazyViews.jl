using MapView
using Base.Test

# write your own tests here
@test 1 == 1

fs = [
  x -> x,
  x -> 2*x,
  x -> sin(x),
  x -> x^3 + 3*x - 2,
  x -> sqrt(x)
];

println("Floating point tests...");
for n=1:10000
  d   =   rand(1:5);
  ns  =   rand(1:25, d);
  a   =   rand(ns...);
  for f in fs
    mv  =   MapView{Float64, d}(a, f);
    @test(mv == map(f, a));
  end
end
println("TEST PASSED.");
