/***************

Project cuBIOSIM
Polytech Paris UPMC

authors:
	Liliane Kissita
	Elise Grojean
	Adrian Ahne
	Lucas Gaudelet

Comments of this forme:
// !! this is a sample comment !!
show where you can modify parameters, files, etc.


****************/

// standard C++
#include <fstream>
#include <iostream>

// repressilator class and solver
#include <repressilator.hh>
#include <runge_kutta.hh>

// CUDA
#include <cuda_runtime.h>
#include <cuda.h>

// command line parser and timer
#include <chCommandLine.h>
#include <chTimer.hpp>

// namespaces
using namespace std;

// Constants
// !! Change parameter here if necessary !!
const static int DEFAULT_N = 3;

const static double Ktl = 1e-2;	// Translation rate
const static double Ktr = 1e-3;	// Transcription rate
const static double KR = 1e-2;  // Strength of repressors
const static double nR = 2;		// Hills coefficient of repressors
const static double dprot = 1e-3;	// Protein degradation rate
const static double dmRNA = 1e-2;	// mRNA degradation rate


// function prototypes
void print_help(char* argv);

// main
int main(int argc, char **argv) {

	// print help
	bool      help = chCommandLineGetBool("h", argc, argv);
	if(!help) help = chCommandLineGetBool("help", argc, argv);
	if(help)  print_help(argv[0]);

	// user gets asked in command line to give a repressilator size
	int n = -1;
	chCommandLineGet<int>(&n, "n", argc, argv);
	chCommandLineGet<int>(&n, "repressor-number", argc, argv);
	n = (n!=-1)? n:DEFAULT_N;

	if( n%2==0 ) {
		cout << "n must be an odd interger" << endl;
		exit(-1);
	}
	else {
		cout << "repressors : " << n
			<< "\tspecies: " << 2*(n+1)
			<< "\treactions: " << 2*n+1 << endl;
	}

	// repressilator initialisation
	// repr_rk4 : solver runge-kutta 4
	// !! Change if necessary output file of results !!
	Repressilator_ODE repr_rk4(n, dprot, dmRNA, Ktl, Ktr, KR, nR, "bin/result_rk4.csv");

	// initial point
	// !! Change if necessary initial value of Y0 !!
	double* Y0 = (double*)calloc(2*(n+1), sizeof(double));	Y0[0] = 1;

	// compute
	// !! Change parameters of solver if necessary !!
	int dim = 2*(n+1); // Number of species (size of input vector)
	double t0 = 0.0; // Start time of simulation
	double t_max = 1000; // End time of simulation
	double step = 1e-2; // Step size
	
	cout << "call rk4...\t" << flush;
	rk4_wrapper<double, Repressilator_ODE&>
			( dim, repr_rk4, Y0 , t0 , t_max, step);
	cout << "done" << endl;

	free(Y0);

	return 0;

}

void print_help( char* argv) {

	cout	<< "Help:" << endl
		<< "  Usage: " << endl
		<< "  " << argv << " [options][-n <repressor-number> ]" << endl
		<< endl
		<< "  -n|--repressor-number" << endl
		<< "      number of repressors to be used, must be an odd integer" << endl
		<< endl;

}
