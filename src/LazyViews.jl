module LazyViews

export AbstractLazyView, MapView, CView, LazyView

using FastAnonymous
typealias LVFunction Union{Function, FastAnonymous.AbstractClosure}

abstract AbstractLazyView;

# Lazy view of a function mapped to an array
immutable MapView{T, N} <: AbstractLazyView
  f::LVFunction;
  a::Array{T, N};

  MapView(f::LVFunction, a::Array{T, N}) = new(f, a);
end

Base.getindex(mv::MapView, idxs...) = mv.f(mv.a[idxs...]);

# Lazy view of a constant multiplied by each element of an array
type CView{T, N} <: AbstractLazyView
  c::Number;
  a::Array{T, N};

  CView(c::Number, a::Array{T, N}) = new(c, a);
end

Base.getindex(cv::CView, idxs...) = cv.c * cv.a[idxs...];

# "Weaker" typed, nestable lazy view
immutable LazyView{T, N} <: AbstractLazyView
  f::LVFunction;
  a::Union{Array{T, N}, LazyView{T, N}};

  LazyView(f::LVFunction, a::Union{Array{T, N}, LazyView{T, N}}) = new(f, a);
end

Base.getindex(lv::LazyView, idxs...) = lv.f(lv.a[idxs...]);
import Base.*
*{T, N}(lv::LazyView{T, N}, c::Number) = LazyView{T, N}(x -> c*x, lv);
*{T, N}(c::Number, lv::LazyView{T, N}) = lv * c;

# Forward size calls to base array
Base.size(amv::AbstractLazyView) = size(amv.a);

import Base.==
function =={T, N}(mv::AbstractLazyView, a::Array{T, N})
  if size(mv) != size(a)
    return false;
  else
    for i in eachindex(a)
      if mv[i] != a[i]; return false; end
    end
    return true;
  end
end
=={T, N}(a::Array{T, N}, mv::AbstractLazyView) = mv == a;

function ==(mv1::AbstractLazyView, mv2::AbstractLazyView)
  if size(mv1) != size(mv2)
    return false;
  else
    for i in eachindex(mv1.a)
      if mv1[i] != mv2[i]; return false; end
    end
    return true;
  end
end

import Base.!=
!={T, N}(mv::AbstractLazyView, a::Array{T, N}) = !(mv == a);
!={T, N}(a::Array{T, N}, mv::AbstractLazyView) = !(mv == a);
!=(mv1::AbstractLazyView, mv2::AbstractLazyView) = !(mv1==mv2);

end # module
