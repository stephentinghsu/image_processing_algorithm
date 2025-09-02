<h1>Image Processing Algorithm on FPGA</h1>

<h2>📖 Overview</h2>
<p>This project implements image processing algorithms on FPGA hardware to improve image quality and support interactive applications.</p>
<p>Two key operations are supported:</p>
<ul>
<li>
<p><strong>Sobel Operator</strong> → Edge detection</p>
</li>
<li>
<p><strong>Median Filter</strong> → Noise removal (salt &amp; pepper noise)</p>
</li>
</ul>
<p>Users can select the processing mode from switch on FPGA board to perform either edge detection or denoising on the selected image. The processed result is displayed on a VGA monitor (1280×1024 @ 60 Hz).</p>
<hr>

<h2>🛠 Development Environment</h2>
<h3>Hardware</h3>
<ul>
  <li>FPGA Board: Xilinx Basys 3</li>
  <li>Peripherals: VGA Display</li>
</ul>
<h3>Software & Tools</h3>
<ul>
  <li>Hardware Description Language (HDL): Verilog HDL</li>
  <li>Simulation: Xilinx Vivado</li>
  <li>Synthesis: Xilinx Vivado</li>
  <li>Implementation: Xilinx Vivado</li>
</ul>
<hr>

<h2>📊 System Architecture</h2>
<p>Schematic of data flow:<br>
<em><img width="306" height="305" alt="Image" src="https://github.com/user-attachments/assets/dc01fd4f-960a-49f0-9465-e8b318632c62" /></em></p>
<hr>

<h2>📂 Core Modules</h2>
<h3><code inline="">top.v</code></h3>
<ul>
<li>
<p>Controls system I/O</p>
</li>
<li>
<p>Routes processed data to VGA output</p>
</li>
<li>
<p>Stores intermediate results in BRAM</p>
</li>
</ul>
<pre><code class="language-verilog">module top(clk, rst, func, red_out, green_out, blue_out, hsync_out, vsync_out);
    input clk, rst, func;
    ...
endmodule</code></pre>
<hr>
<h3><code inline="">operate.v</code></h3>
<ul>
<li>
<p>Loads 3×3 image pixels from BRAM</p>
</li>
<li>
<p>Sends pixels to both <code inline="">sobel.v</code> and <code inline="">median.v</code></p>
</li>
<li>
<p>Selects output based on <code inline="">func</code></p>
</li>
</ul>
<pre><code class="language-verilog">sobel sobel_op(.p0(p0), .p1(p1), ..., .out(sobel_result));
median median_op(.p0(p0), .p1(p1), ..., .out(median_result));

assign result_data = (func) ? sobel_result : median_result;</code></pre>
<hr>
<h3><code inline="">sobel.v</code></h3>
<ul>
<li>
<p>Performs edge detection using Sobel kernels</p>
</li>
</ul>
<em><img width="200" height="100" alt="Image" src="https://github.com/user-attachments/assets/76b72db1-b36c-4ae2-8784-2c877f5f748e" /></em></p>
<em><img width="200" height="100" alt="Image" src="https://github.com/user-attachments/assets/a84d3d97-20f2-443f-86ef-88ff993f7c65" /></em></p>
<hr>

<h3><code inline="">median.v</code></h3>
<ul>
<li>
<p>Removes noise by selecting the median value from the 3×3 window.</p>
</li>
</ul>
<pre><code class="language-verilog">always @(*) begin
    // Sort the 9 input pixels and select the middle value
    // (Pseudo-code representation)
    out = median(p0, p1, p2, p3, p4, p5, p6, p7, p8);
end</code></pre>
<hr>

<h2>🔄 Flowchart</h2>
<p><em><img width="535" height="680" alt="Image" src="https://github.com/user-attachments/assets/c6a630d6-1963-45a4-bfd1-5680e45b2604" /></em></p>
<hr>

<h2>🖥 Simulation Results</h2>
<ol>
<li>
<p><strong>Processing all 10,000 pixels</strong></p>
<ul>
<li>
<p>Counter stops at 10,000</p>
</li>
<li>
<p>Address range: 0 → 9999</p>
</li>
</ul>
</li>
<p><em><img width="1616" height="489" alt="Image" src="https://github.com/user-attachments/assets/51495ffb-5c5e-4a10-bca3-e9afb3daf5d3" /></em></p>

<li>
<p><strong>Function selection</strong></p>
<ul>
<li>
<p><code inline="">func = 1</code>: Sobel operator</p>
</li>
<li>
<p><code inline="">func = 0</code>: Median filter</p>
</li>
</ul>
</li>
<p><em><img width="1605" height="418" alt="Image" src="https://github.com/user-attachments/assets/fc013105-2ebc-413e-8f1e-9348d7f42a67" /></em></p>

<li>
<p><strong>VGA Synchronization</strong></p>
<ul>
<li>
<p>Horizontal &amp; vertical counters verify sync signals</p>
</li>
<li>
<p>Porch timing ensures correct display</p>
</li>
</ul>
</li>
<p><em><img width="1606" height="502" alt="Image" src="https://github.com/user-attachments/assets/2408fcdf-d275-4132-bf52-5c4dca4873c2" /></em></p>
<p><em><img width="1613" height="504" alt="Image" src="https://github.com/user-attachments/assets/9938c2d7-bb0a-4ccf-9581-d166b401b9e6" /></em></p>

</ol>
<hr>

<h2>🖼️ Demonstration</h2>
<p>Here are images demonstrating the system's output for both the Sobel and Median filters.</p>

<p><b>Original Input Image:</b></p>
<p><em><img width="160" height="160" alt="Image" src="https://github.com/user-attachments/assets/87947e0f-c6d3-4bf1-9c28-08631d2ff80d" /></em></p>

<p><b>Sobel Edge Detection Output:</b></p>
<p><em><img width="160" height="160" alt="Image" src="https://github.com/user-attachments/assets/bb2b8ec4-a54d-4c1c-8ca7-6fa10968cb95" /></em></p>

<p><b>Median Noise Reduction Output:</b></p>
<p><em><img width="160" height="160" alt="Image" src="https://github.com/user-attachments/assets/abc43de0-830b-4599-9a6f-c5ee3943714a" /></em></p>

<hr>

<h2>🚀 How to Run</h2>
<ol>
<li>
<p>Load design onto FPGA (with BRAM initialized with image data).</p>
</li>
<li>
<p>Connect VGA monitor (1280×1024 @ 60 Hz).</p>
</li>
<li>
<p>Provide control signals:</p>
<ul>
<li>
<p><code inline="">rst</code>: Reset</p>
</li>
<li>
<p><code inline="">func</code>: Select processing mode (<code inline="">1 = Sobel</code>, <code inline="">0 = Median</code>)</p>
</li>
</ul>
</li>
<li>
<p>Observe processed image on VGA output.</p>
</li>
</ol>
<hr>

<h2>🧩 Alternative Implementation</h2>
<p>
There is also a version implemented using system functions 
(<code>fopen</code>, <code>fwrite</code>, <code>fclose</code>). 
This version cannot be synthesized or deployed on the FPGA board, 
but it can be used for simulation and functional verification.
</p>
<hr>

<h2>📌 References</h2>
<ul>
  <li>
    VGA介面原理與Verilog實現 <br>
    <a href="https://www.cnblogs.com/liujinggang/p/9690504.html" target="_blank">
      https://www.cnblogs.com/liujinggang/p/9690504.html
    </a>
  </li>
  <li>
    Sobel Core Module Verilog Code <br>
    <a href="https://edge.kitiyo.com/2009/codes/sobel-core-verilog-module.html" target="_blank">
      https://edge.kitiyo.com/2009/codes/sobel-core-verilog-module.html
    </a>
  </li>
</ul>

</body></html>
