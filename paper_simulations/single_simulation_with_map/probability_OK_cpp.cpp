/* probability_OK_cpp
 * Computes the probability as probabilityOK.m
*/

#include "mex.hpp"
#include "mexAdapter.hpp"

#include <vector>
#include <math.h>       /* cos,sin */

#include <boost/geometry.hpp>
#include <boost/geometry/geometries/point_xy.hpp>
#include <boost/geometry/geometries/polygon.hpp>

#include <boost/foreach.hpp>

#include <boost/geometry/geometries/adapted/c_array.hpp>

BOOST_GEOMETRY_REGISTER_C_ARRAY_CS(cs::cartesian)

using namespace matlab::data;
using matlab::mex::ArgumentList;

class MexFunction : public matlab::mex::Function {
public:
    void operator()(ArgumentList outputs, ArgumentList inputs) {
        typedef boost::geometry::model::d2::point_xy<double> point;
        typedef boost::geometry::model::polygon<point> polygon;  
        typedef boost::geometry::model::multi_polygon<polygon> multi_polygon;
        
        //Inputs are points, lambda, Lmax, N_grid
        
        const double lambda = inputs[1][0];
        const double Lmax = inputs[2][0];
        const double N_grid = inputs[3][0];
        int N1 = std::ceil(std::sqrt(N_grid));
        int N2 = std::ceil(N_grid/N1);
                
        int n = inputs[0].getNumberOfElements()/2;
        TypedArray<double> points = std::move(inputs[0]);
        
        double total_area = 0.0;
        double dl = Lmax/N1, dtheta = M_PI/N2;
        double l, theta, l_cos_theta, l_sin_theta, x, y, sum_aux, p_area;
        
        for (int n1 = 1; n1 <= N1; n1++) {
            l = n1*dl;
            sum_aux = 0.0;
            for (int n2 = 1; n2 <= N2; n2++) {
                theta = n2*dtheta;
                l_cos_theta = l * 0.5 * std::cos(theta);
                l_sin_theta = l * 0.5 * std::sin(theta);
                multi_polygon union_rectangles, tmp_union;
                for (int i = 0; i < n; ++i) {
                    x = points[i][0];
                    y = points[i][1];    
                    double points_rectangle[4][2] = {
                        {-l_cos_theta,-l_sin_theta},
                        {x-l_cos_theta,y-l_sin_theta},
                        {x+l_cos_theta,y+l_sin_theta}, 
                        {l_cos_theta,l_sin_theta}
                    };
                    polygon rectangle;
                    boost::geometry::append(rectangle, points_rectangle); //makes polygon
                    boost::geometry::correct(rectangle); // orients the points well
                    if (boost::geometry::area(rectangle) > 1e-10) { //we check points form a polygon, if not multipolygon bugs
                        boost::geometry::clear(tmp_union); //tmp_union  is a multipolygon
                        boost::geometry::union_(union_rectangles, rectangle, tmp_union);
                        union_rectangles = tmp_union;
                    }
                }
                //we will iterate through each disjoint polygon of the multipolygon
                p_area = 0.0;
                BOOST_FOREACH(polygon const& p, union_rectangles) 
                    p_area += boost::geometry::area(p);
                sum_aux += p_area*dtheta;
            }
            total_area += sum_aux*dl;
        }
        ArrayFactory factory;
        outputs[0] = factory.createScalar(std::exp(-lambda*total_area/(M_PI*Lmax)));
    }
};
