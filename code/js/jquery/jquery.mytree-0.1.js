(function($){
    var t = function () {
        return "v0.1";
    };

    // utilities
    var u = {
    };

    t.build = function() {
        var root = Object.create(t);  // firstly inherit from t (for chain-call)
        

        return root;
    }

    $.fn.myTree = t;
}(jQuery));
